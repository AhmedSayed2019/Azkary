# Phase 2 Handoff: Build `layout_repository.dart` Against the Real QUL Schema

This document unblocks Phase 2 of the multi-mushaf project. Read it together with the master spec (`multi_mushaf_prompt.md`). Where this doc adds detail, it wins; where it is silent, the master spec applies unchanged.

## What changed since your last stop

You stopped correctly at the master spec's stop condition: no schema dump and no fixture. Both are now provided:

1. The fixture file is placed at `test/fixtures/layout_qcf_v2.db` (verify it exists before starting; if it doesn't, STOP and ask me — do not proceed without it).
2. The full schema dump from that exact file is embedded below. It was extracted from the real QUL QCF V2 (1421H print) 15-line layout database, mirrored at `github.com/blueheron786/quranic-universal-library-mushaf-layouts`.

You are cleared to build, in this order: `layout_repository.dart` → its unit tests against the fixture → `mushaf_downloader.dart` (own implementation, per the master spec's FORBIDDEN rule on quran_library internals).

## Real schema dump (source of truth — write all SQL against this)

```
=== .schema ===
CREATE TABLE pages (page_number INTEGER, line_number INTEGER, line_type TEXT, is_centered INTEGER, first_word_id INTEGER, last_word_id INTEGER, surah_number INTEGER)
CREATE TABLE info (name TEXT, number_of_pages INTEGER, lines_per_page INTEGER, font_name TEXT)

=== SELECT * FROM info ===
('QCF V2 ( 1421H print )', 604, 15, 'v2')

=== SELECT * FROM pages ORDER BY page_number, line_number LIMIT 20 ===
(1, 1, 'surah_name', 1, '', '', 1)
(1, 2, 'ayah', 1, 1, 5, '')
(1, 3, 'ayah', 1, 6, 10, '')
(1, 4, 'ayah', 1, 11, 17, '')
(1, 5, 'ayah', 1, 18, 23, '')
(1, 6, 'ayah', 1, 24, 29, '')
(1, 7, 'ayah', 1, 30, 33, '')
(1, 8, 'ayah', 1, 34, 36, '')
(2, 1, 'surah_name', 1, '', '', 2)
(2, 2, 'basmallah', 1, '', '', '')
(2, 3, 'ayah', 1, 37, 44, '')
(2, 4, 'ayah', 1, 45, 51, '')
(2, 5, 'ayah', 1, 52, 59, '')
(2, 6, 'ayah', 1, 60, 68, '')
(2, 7, 'ayah', 1, 69, 74, '')
(2, 8, 'ayah', 1, 75, 77, '')
(3, 1, 'ayah', 0, 78, 86, '')
(3, 2, 'ayah', 0, 87, 96, '')
(3, 3, 'ayah', 0, 97, 104, '')
(3, 4, 'ayah', 0, 105, 114, '')

=== SELECT * FROM pages WHERE page_number=604 ===
(604, 1, 'surah_name', 1, '', '', 112)
(604, 2, 'basmallah', 1, '', '', '')
(604, 3, 'ayah', 0, 83596, 83608, '')
(604, 4, 'ayah', 1, 83609, 83614, '')
(604, 5, 'surah_name', 1, '', '', 113)
(604, 6, 'basmallah', 1, '', '', '')
(604, 7, 'ayah', 0, 83615, 83626, '')
(604, 8, 'ayah', 0, 83627, 83636, '')
(604, 9, 'ayah', 1, 83637, 83642, '')
(604, 10, 'surah_name', 1, '', '', 114)
(604, 11, 'basmallah', 1, '', '', '')
(604, 12, 'ayah', 0, 83643, 83651, '')
(604, 13, 'ayah', 0, 83652, 83659, '')
(604, 14, 'ayah', 1, 83660, 83664, '')
(604, 15, 'ayah', 1, 83665, 83668, '')

=== DISTINCT line_type ===
surah_name
ayah
basmallah

=== STATS ===
total line rows: 9046
max page: 604
max word id: 83668
```

## Critical facts about this database (each one changes your code)

1. **There is NO words table in the layout DB.** Word glyph text lives in a SEPARATE QUL export — the "Quran script — QPC V2 word-by-word" database — joined via `first_word_id`/`last_word_id`. Word ids are global `1..83668` across the whole Quran.
2. **Type quirks:** `first_word_id`, `last_word_id`, and `surah_number` contain TEXT `''` (empty string, NOT NULL) on `surah_name`/`basmallah` lines, and storage classes are mixed text/integer elsewhere. Every numeric comparison must `CAST(... AS INTEGER)` and treat `''` as null. Silent wrong results will occur otherwise.
3. **`line_type` values are exactly:** `surah_name | ayah | basmallah`. `surah_number` is populated only on `surah_name` lines.
4. **Pages 1–2 have 8 lines, not 15.** Never hardcode 15 lines when iterating; read the actual rows per page. (`info.lines_per_page` describes the nominal grid, not every page.)
5. **No PRIMARY KEY, no indexes.** With 9,046 rows queries are trivial as-is; adding an index on `page_number` at open time is optional.

## Spec amendment 1: two-database design for LayoutRepository

Because glyph text lives in a second DB, `LayoutRepository` must be designed NOW to accept two database handles per mushaf:

```dart
class LayoutRepository {
  // layoutDb  : test/fixtures/layout_qcf_v2.db  (schema above)      — AVAILABLE
  // scriptDb  : QUL "QPC V2 word-by-word" export (words/glyph text) — NOT YET PROVIDED
}
```

Rules for the missing script DB:

- Implement fully everything that needs only the layout DB: `getPageLines`, `getPageForAyah` mapping via word-id ranges where possible, `getFirstAyahOfPage` structure, page/line iteration.
- Any method that needs glyph text (`PageLine.glyphText`, `getWordsOfPage`) gets a clean seam: define the interface, implement against `scriptDb`, and guard with a clear `// TODO(script-db): blocked on QPC V2 word-by-word export` plus a thrown `StateError` with an explanatory message if called before the script DB is attached. **Do NOT invent the script DB's schema, do NOT stub fake glyph data silently, and do NOT block overall progress waiting for it.** When I provide the file, I will also provide its schema dump the same way.
- Note: mapping surah/ayah ↔ word-id ranges also lives in the script DB. Until it arrives, `getPageForAyah`/`getFirstAyahOfPage` may only be implementable down to word-id level; leave the surah/ayah translation behind the same TODO seam.

## Spec amendment 2: first-launch UX decision (settled — do not revisit)

- The app keeps working immediately on first launch using the existing `quran_library` fallback rendering. Mushaf packages (fonts + DBs) are **download-on-demand only**.
- No forced onboarding download. No fonts bundled in the APK/AAB.
- **Play Asset Delivery is explicitly deferred — do not build it, do not scaffold for it.** It may be revisited post-launch based on analytics only.
- The `mushaf_switcher` UI must show each mushaf's download size before install and a delete action for installed mushafs (`deleteMushaf` per master spec), so low-storage users can keep only one.

## Deliverables for this phase

1. `lib/mushaf/data/layout_repository.dart` implemented against the schema above, with the two-DB seam.
2. Unit tests running against `test/fixtures/layout_qcf_v2.db` covering at minimum: page 1 (8 lines, all centered, surah header), page 2 (basmallah line), page 42 (15 plain ayah lines), page 604 (three surah headers + basmallah lines + centered last lines), the `''`-as-null casting behavior, and total row/page counts matching the STATS block.
3. `lib/mushaf/data/mushaf_downloader.dart` (own implementation; unit-test extraction + sha256 verification against local files — no real URLs yet, registry `downloadUrl` fields stay empty per the master spec's Hosting Decision).
4. A short summary of what is behind the `TODO(script-db)` seam, so I know exactly what unblocks next.

Stop after these deliverables and report before touching the font manager or page builder.
