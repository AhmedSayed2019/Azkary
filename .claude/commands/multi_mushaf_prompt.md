# Task: Multi-Mushaf Rendering Engine for Flutter Quran App

## Context

I have an existing Flutter Quran app that currently uses the `quran_library` package (v4.2.1, by alheekmahlib) to display the Madani Mushaf (QCF V2 fonts, Hafs narration). I want to build a **unified, standalone mushaf rendering engine** that supports **multiple mushaf styles with runtime switching**, while keeping `quran_library` only as a data/services layer (audio playback, tafsir, search, bookmarks — these work by surah/ayah numbers and are layout-independent).

## Current Status (do not redo completed work)

Already built and reviewed:

- `lib/mushaf/data/mushaf_registry.dart` — `MushafDefinition` model + `mushafs` list with the 3 entries below. `downloadUrl` fields are empty placeholders (see Hosting Decision).
- `lib/mushaf/README.md` — status doc with architecture and plan.

Next up, in this order: `layout_repository.dart` (blocked on the schema dump below) → `mushaf_downloader.dart` → `page_font_manager.dart` → `mushaf_page_builder.dart` → visual validation → remaining mushafs + switcher UI.

Target mushafs (all sourced from QUL — Quranic Universal Library, qul.tarteel.ai):

1. `qcf_v2` — Madani Mushaf, 604 pages, 15 lines/page (current default)
2. `qcf_v4` — Tajweed color-coded Mushaf, 604 pages, 15 lines/page
3. `indopak_15` — Indopak Nastaleeq Mushaf, ~610 pages, 15 lines/page

## CRITICAL: Verify before coding — do NOT invent schemas

Before writing ANY repository or query code:

1. I will provide the actual schema of the QUL layout database, obtained by running against a real downloaded `layout.db` (from `qul.tarteel.ai/resources/mushaf-layouts`):

   ```bash
   sqlite3 layout.db ".schema"
   sqlite3 layout.db "SELECT * FROM pages LIMIT 20;"   # adapt table names to what .schema shows
   sqlite3 layout.db "SELECT * FROM words LIMIT 20;"
   ```

   Write ALL queries in `layout_repository.dart` against this ACTUAL schema. QUL export formats vary between versions — never assume column names.
2. The sample `layout.db` file itself lives at `test/fixtures/layout_qcf_v2.db` and is the fixture for the `LayoutRepository` unit tests.
3. If neither the schema dump (pasted in chat) nor the fixture file is available, STOP and ask me for them. Do not stub fake data silently.
4. Sample page font files (ttf) from `qul.tarteel.ai/resources/font` go in `test/fixtures/fonts/` when font-rendering work begins.

## Architecture (follow this structure)

```
lib/mushaf/
├── data/
│   ├── mushaf_registry.dart      # Static definitions of available mushafs
│   ├── mushaf_downloader.dart    # Download zip (fonts + layout.db), extract, verify
│   └── layout_repository.dart    # Read-only sqlite access to layout data
├── engine/
│   ├── page_font_manager.dart    # Per-page FontLoader with cache + preloading
│   └── mushaf_page_builder.dart  # Builds one page widget from layout lines
└── ui/
    ├── mushaf_screen.dart        # RTL horizontal PageView, gesture handling
    ├── mushaf_switcher.dart      # Bottom sheet to pick/download mushafs
    └── ayah_overlay.dart         # Tap-to-select ayah highlight layer
```

## Detailed Requirements

### 1. MushafDefinition + Registry

```dart
class MushafDefinition {
  final String id;           // 'qcf_v2' | 'qcf_v4' | 'indopak_15'
  final String nameAr;
  final String nameEn;
  final int totalPages;
  final int linesPerPage;
  final String downloadUrl;  // zip containing fonts/ dir + layout.db
  final int approxSizeMB;
  final String checksumSha256; // of the zip
}
```

- Registry is a hardcoded const list. Do NOT hardcode QUL URLs for production use.

#### Hosting Decision (settled)

Packages will be hosted on **Cloudflare R2** (free tier: 10 GB storage, zero egress fees — the 3 mushaf zips total <300 MB). Final URL pattern:

```
https://<bucket>.r2.dev/mushafs/qcf_v2.zip
https://<bucket>.r2.dev/mushafs/qcf_v4.zip
https://<bucket>.r2.dev/mushafs/indopak_15.zip
```

Each zip contains:

```
fonts/p1.ttf ... p{totalPages}.ttf
layout.db
```

Keep `downloadUrl` empty in the registry until Phase 5 (visual validation) passes — the downloader is built and unit-tested earlier, but real URLs and uploaded packages come only after the renderer is proven against local files. Building against local extracted directories first is the required workflow, not a shortcut.

### 2. Downloader

- **FORBIDDEN: importing `ZipDownloadService` (or anything else) from `quran_library`'s `src/` internals.** Those are not public API and any package update can break the app silently. If its implementation is a good reference, COPY the relevant code into `mushaf_downloader.dart` with an attribution comment (quran_library is MIT-licensed, copying is fine) — or write it fresh; it is essentially `dio` + `archive` in ~50 lines. Only public exports of `quran_library` may be imported anywhere in this project.
- Uses `dio` with progress stream (percent for UI progress bar).
- Downloads `{id}.zip` → extracts to `{appSupportDir}/mushafs/{id}/` → verifies sha256 → writes a `manifest.json` marker file only on success (this marker = "installed").
- Resumable is nice-to-have, NOT required. Handle: no connectivity, interrupted download (delete partial), insufficient storage.
- `deleteMushaf(id)` removes the directory. `qcf_v2` may ship differently later; treat all mushafs uniformly for now.

### 3. LayoutRepository

- Opens `{dir}/mushafs/{id}/layout.db` read-only (use `sqflite` or `drift` — match whatever the host project already uses; check pubspec first).
- API (adapt internals to the real schema you inspected):

```dart
Future<List<PageLine>> getPageLines(String mushafId, int pageNumber);
Future<int> getPageForAyah(String mushafId, int surah, int ayah);
Future<(int surah, int ayah)> getFirstAyahOfPage(String mushafId, int page);
Future<List<WordBounds>> getWordsOfPage(String mushafId, int page); // for tap detection
```

- `PageLine` carries: lineNumber, lineType (`surahName` | `basmallah` | `ayah`), isCentered, glyph text (the mushaf-specific encoded text), and the surah/ayah range covered by the line.
- Cache open DB handles per mushafId. Close on mushaf switch/delete.

### 4. PageFontManager

- Font family naming convention: `{mushafId}-p{page}` (e.g. `qcf_v2-p42`).
- `ensureLoaded(mushafId, page)` → loads ttf via `FontLoader`, idempotent, returns family name.
- `preloadAround(mushafId, page)` → fire-and-forget preload of pages ±2 for smooth swiping.
- IMPORTANT: Flutter cannot unload fonts. Do NOT attempt eviction. Just track the loaded set. Document this limitation in a code comment.

### 5. MushafPageBuilder

- Renders exactly `linesPerPage` lines in a Column with fixed line-height distribution (like printed mushaf), NOT natural text flow.
- Line rendering rules:
  - `surahName` → decorative banner widget (SVG frame + surah name; reuse assets if the host app has them, otherwise simple styled container placeholder with a TODO).
  - `basmallah` → centered, scaled down.
  - `ayah` line, `isCentered == false` → full-width justified: `SizedBox(width: double.infinity, child: FittedBox(fit: BoxFit.fill, child: Text(...)))`. QCF lines are designed near-constant-width so the stretch is imperceptible.
  - `ayah` line, `isCentered == true` (last lines of surahs, page 1-2 style) → `BoxFit.scaleDown`, centered.
- Font size base 23.4 logical px, scaled by a user-adjustable factor (persisted).
- Page footer: page number + juz/hizb label (get juz/hizb from `quran_library` utils, they are layout-independent).
- First render of a page must await `ensureLoaded`; show a lightweight shimmer/placeholder while the font loads (should be <100ms from disk).

### 6. MushafScreen

- `PageView.builder`, `reverse: false` with RTL directionality so swiping matches Arabic book direction (page 1 on the right). Verify swipe direction matches the existing quran_library screen behavior.
- State: `currentMushafId`, `currentPage`, persisted via the host project's existing storage (check for get_storage/shared_preferences in pubspec and reuse).
- **Switching rule (critical):** switching mushafs must preserve READING POSITION BY AYAH, not by page number, because pagination differs between mushafs:

```dart
final (surah, ayah) = await repo.getFirstAyahOfPage(oldId, currentPage);
final newPage = await repo.getPageForAyah(newId, surah, ayah);
```

- Tap on a word/ayah → resolve via `getWordsOfPage` bounds → highlight the full ayah (semi-transparent overlay rectangles per line segment) → show the existing action menu that calls `quran_library` services (`playAyah`, tafsir). If precise word bounds are not available in the layout DB, fall back to line-level ayah resolution and note it.

### 7. MushafSwitcher UI

- Bottom sheet listing registry entries with three states: installed (radio select), not installed (download button + size), downloading (progress + cancel).
- Switching to a non-installed mushaf prompts download first.
- All UI text in Arabic, RTL.

### 8. State management

- Inspect the host project first: if it already uses GetX (quran_library depends on `get`), use GetX controllers to stay consistent. Do not introduce Riverpod/Bloc into a GetX project.

## Acceptance Criteria

1. Page 1, 2, 42, 255-area pages (Ayat al-Kursi), 604 render pixel-comparable to the printed mushaf for `qcf_v2` — compare side-by-side against the existing `quran_library` screen.
2. Switching qcf_v2 → indopak_15 while on page 42 lands on the indopak page containing the same first ayah.
3. Cold start to first page render < 1s on a mid-range Android device (fonts read from disk, no network).
4. Swiping 20 pages fast produces no jank (preloading works) — verify with DevTools performance overlay.
5. Airplane mode: installed mushafs fully usable; non-installed show a clear offline error.
6. `useMaterial3: false` requirement of quran_library must not be violated by any new theme code.
7. No regressions to existing audio/tafsir/bookmark features.

## Deliverables

1. All code under `lib/mushaf/` as specified.
2. A `README_MUSHAF.md` explaining: how to prepare a mushaf zip for my server (exact folder structure + how to export layout DB from QUL), and how to add a 4th mushaf later.
3. Unit tests for `LayoutRepository` (against the real sample DB) and the ayah-position-preserving switch logic.
4. A short migration note: which parts of the old `QuranLibraryScreen` usage to remove once the new engine is validated.

## Working Style

- Work incrementally: (1) ~~registry~~ DONE, (2) layout repo against the real schema dump + fixture at `test/fixtures/layout_qcf_v2.db`, (3) downloader (own implementation per the FORBIDDEN rule above; unit-test extraction/verification against local files — no real URLs yet), (4) font manager, (5) page builder for qcf_v2 only, reading from a local extracted directory, (6) visual validation vs quran_library side-by-side, (7) remaining mushafs + switcher (R2 URLs get filled in here, after I upload the packages), (8) tap/highlight integration.
- After step 6, STOP and show me screenshots/comparison before continuing.
- Ask me before adding any new package dependency.
