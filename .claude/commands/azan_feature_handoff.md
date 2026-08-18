# Azan Feature — Session Handoff (2026-08-18, branch `azan`)

Continuation doc for the azan/prayer-times work. Read this first when resuming.
Branch: **`azan`** (off `fix/build-and-runtime-errors`, pushed to `origin/azan`).

---

## What is DONE and verified on the emulator

### 1. Prayer times (display)
- `lib/features/prayer/prayer_times_service.dart` — fully-local calculation
  (`adhan` package), cached GPS location + reverse-geocoded city (`geocoding`),
  method/madhab persisted in SharedPreferences (`prayer_method`/`prayer_madhab`),
  Cairo/egyptian defaults. `compute()` returns a `PrayerDay` (all 6 slots, the
  5 prayers, next/previous, progress/remaining helpers).
- `lib/features/home/widgets/azan/azan_section.dart` — home sliver: gold hijri +
  gregorian date line, next-prayer name/location + GPS-refresh button (right),
  compact countdown ring (left), floating five-prayer card half over the green.
  Ticker recomputes the day **only** when crossing into a new prayer window.
- `lib/features/prayer/prayer_times_screen.dart` — full screen: countdown header
  (hour/min/sec boxes), hijri/gregorian day navigator (‹ ›), six prayer rows with
  per-prayer **sound toggle** (`prayer_sound_<id.name>`) and per-day **done
  checkbox** (`prayer_done_<yyyy-MM-dd>_<id.name>`), "صلوات اليوم" progress bar.
  Calculation-method sheet now **persists** the choice (`_selectMethod` →
  `service.setMethod` → recompute + reschedule) and shows a ✓ on the current one.

### 2. Home layout (slivers)
- `lib/features/home/home_page.dart` — `CustomScrollView`:
  pinned `SliverAppBar` = ONE row (menu ☰ + zekr search field + bell 🔔) over the
  star pattern, never hides; `AzanSection` scrolls away beneath it; then the
  categories grid. **No explicit physics** (user removed `BouncingScrollPhysics`;
  Android default clamping = no over-scroll gap. iOS default bounce would show
  the gap again — fix later with a single stretch-SliverAppBar if needed).
- Menu sheet has a **dark-mode SwitchListTile** → `ThemeHelper.changeTheme`.

### 3. Theme (light + dark, working)
- `lib/core/res/color.dart` — new palette: greenDeep `#0D4429` / green `#166534`
  (dark primary), gold `#E9C46A` (on green only — `rateColor`), goldDeep
  `#A8801E` (on light surfaces — `goldDeepColor`), surfaces `#F3F2ED`/`#FFFDF7`/
  cream cards `#EAE9D9` (old cream kept in light)/borders `#E7E4D8`; dark:
  `#0B1710`/`#12241A`/`#17301F`/`#1E3527`; ink `#1D2E22`/`#E8EDE8`.
- **Fixed the real bug:** `ColorModel.themeColor` was hardcoded to `lightColor`;
  now resolves via `ThemeHelper` (appContext + Provider) → dark mode works
  app-wide. `dark_mode` key added to ALL 9 translation files.
- Categories side-rail (`lib/widgets/Custom_drawer/custom_drawer.dart`) uses
  `AppColor.primaryColor.themeColor` instead of legacy `teal`.

### 4. Star-pattern header
- Asset `assets/images/background/home_header_bacground.svg` — generated 8-point
  star tile grid, currently pitch `368/24 ≈ 15.33` (⅓ of original size, 720
  stars, stroke 0.7, `currentColor`). Regenerate with the python snippet in the
  git history (commit `5e7969d`) if the size needs tuning — `PITCH` is the knob.
- `lib/widgets/islamic_header_background.dart` — shared widget (green ground +
  gold-tinted SVG at 10% opacity, `RepaintBoundary`, optional `height`),
  precached in `main()`. Used by: home pinned bar, azan section, azkar reading
  app bar (pattern outside `FlexibleSpaceBar` so it survives collapse), and the
  categories screen app bar.
- Azkar reading screen (`lib/features/azkar/view_azkar.dart` + its
  `components/app_bar.dart`) is a `CustomScrollView` with a pinned SliverAppBar
  (expandedHeight 140, shrinking title).

### 5. Azan sound scheduling
- `lib/features/prayer/azan_scheduler.dart` — `AzanScheduler.reschedule()`:
  - timezone init (`flutter_timezone` + `timezone`), one-time guard.
  - cancels its own id range (7000–7099; legacy notifiers use 0–5).
  - schedules `zonedSchedule` **exactAllowWhileIdle** notifications for the next
    **2 days** of the 5 prayers, skipping past times and muted prayers
    (`prayer_sound_<id.name>` prefs — same keys the prayer screen toggles).
  - Android: channel `azan_channel`, full adhan sound
    `RawResourceAndroidNotificationSound('adhan_mecca')`
    (file: `android/app/src/main/res/raw/adhan_mecca.mp3`), category alarm,
    small icon `'icon'`, and `audioAttributesUsage: AudioAttributesUsage.alarm`
    so the adhan plays on the **alarm** stream (alarm volume, not the
    notification volume, and not truncated).
  - iOS: `DarwinNotificationDetails` with **default system sound** +
    timeSensitive. Custom adhan needs a ≤30s `.caf` added via Xcode (see TODO).
  - falls back to `inexactAllowWhileIdle` when exact alarms aren't permitted;
    never throws (best-effort with debugPrint).
  - `reschedule()` calls are **serialised** through a static `_inFlight` future:
    `main()` and `AzanSection` fire it within milliseconds of each other, and
    interleaving cancel-then-schedule would leave a half-built schedule.
  - `canScheduleExact()` / `requestExactAlarmPermission()` expose the Android
    12+ exact-alarm state to the UI (see the prayer screen banner below).
  - `_clearLegacyAlarms()` kills the old AndroidAlarmManager adhan once.
- Rescheduling hooks: `main()` on every launch (`unawaited`), `AzanSection`
  after init/location refresh, prayer screen on sound toggle + method change.
- `AndroidManifest.xml`: added `ScheduledNotificationReceiver` +
  `ScheduledNotificationBootReceiver` (BOOT_COMPLETED / MY_PACKAGE_REPLACED /
  QUICKBOOT) — without these zonedSchedule never fires. `SCHEDULE_EXACT_ALARM`,
  `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED` were already present.

### 6. Exact-alarm prompt (Android 12+)

`prayer_times_screen.dart` shows a gold `_ExactAlarmNotice` banner
("فعّل المنبهات الدقيقة") between the day navigator and the prayer rows,
**only** when `AzanScheduler.canScheduleExact()` is false. Tapping it opens
`Settings$AlarmsAndRemindersAppActivity`; the screen is a
`WidgetsBindingObserver` and re-checks on `resumed`, hides the banner and
reschedules (verified: the 6 alarms flipped from `window=+1h` to `window=0`).

This matters more than it looks: with `targetSdk 36`, `SCHEDULE_EXACT_ALARM`
is **denied by default**, so out of the box every azan was landing in a
one-hour inexact window. The alternative is `USE_EXACT_ALARM` (auto-granted,
no prompt) — Play policy allows it for alarm-clock-type apps and an adhan
plausibly qualifies, but it is a store-review risk, so that call is left to
the owner.

**Verification (done 2026-08-18 on emulator-5554, Android 15 / API 35,
targetSdk 36 — all of the following was observed, not assumed):**
- `AzanScheduler: scheduled 6 azan notifications` in the log (rest of today +
  all of tomorrow), and `AzanScheduler: legacy adhan alarm cleared`.
- `adb shell dumpsys alarm` → exactly 6 `ScheduledNotificationReceiver` alarms,
  no duplicates, matching the on-screen times.
- Permission denied path: alarms scheduled with `window=+1h` (inexact fallback).
  After granting: `window=0 exactAllowReason=permission` on all 6.
- Notification actually fired (clock jumped to 20:55:50, isha at 20:56):
  id 7000, `channel=azan_channel`, `importance=5`, `category=alarm`,
  title `حان الآن وقت صلاة العشاء`,
  channel sound `android.resource://…/raw/adhan_mecca`,
  `mAudioAttributes usage=USAGE_ALARM`.
- Re-verified from a clean `pm clear` install (fresh channel + fresh prefs).

Still pending: a **real device** run (Doze/battery-optimisation behaviour and
the audible adhan) — the emulator confirms scheduling and the sound URI, not
the speaker.

---

## Known issues / decisions to remember

- **Legacy adhan scheduling is now OFF (done).** `AdanLocationProvider`
  no longer calls `scheduleNotification` from its `notifyListeners` override —
  that call was firing a second adhan on different times/settings. The provider
  is kept because the qibla screen and the "nearby mosque" card read the
  location from it. `AzanScheduler._clearLegacyAlarms` also cancels the
  leftover `AndroidAlarmManager` alarm (id 0) + its notification once per
  device (`azan_legacy_alarms_cleared` pref) — the old system rescheduled
  itself after every fire, so removing the call alone was not enough.
  The rest of `lib/features/adhan/` is dead UI (`AdhanScreen` has been
  commented out of `categories_view.dart` for a while); deleting it is a
  separate cleanup.
- **`ic_notify` never existed.** Both the scheduler and `notifiers.dart` were
  initialising with `AndroidInitializationSettings('ic_notify')`, which throws
  `PlatformException(invalid_icon)` — that is why nothing was ever scheduled.
  The only real drawable is `res/drawable/icon.png`, so both now use `'icon'`,
  and the azan notification pins `icon: 'icon'` on the details as well (the
  plugin is a singleton, so whichever `initialize()` ran last would otherwise
  decide the default icon).
- **`azan_channel` settings are frozen after first creation.** Android ignores
  changes to a channel's sound/importance/audio-usage once it exists. Any
  device that ran a build before the `USAGE_ALARM` change keeps the old
  notification-stream channel until the app is reinstalled. Fine now
  (unreleased); if the channel definition changes again after release, bump the
  channel id (e.g. `azan_channel_v2`) instead of editing it in place.
- iOS: no custom adhan sound yet (needs ≤30s `adhan_short.caf` in the Runner
  bundle via Xcode on a Mac; then set `sound: 'adhan_short.caf'` in
  `DarwinNotificationDetails`). iOS notification sounds are hard-capped at 30s;
  full adhan requires the app to be open or Critical Alerts entitlement.
- `flutter run` on this machine: metadata_god's cargokit build fails with a
  Rust `link.exe` error every build — **harmless**, the APK still builds.
- Emulator taps for testing left some prayer "done"/sound state in prefs —
  device state only.
- Legacy `teal` MaterialColor still used across menu tiles/category text — a
  sweep to `AppColor` tokens was offered but not requested yet.

## User experiments that were committed as-is

The tweaks that were sitting uncommitted in the working tree were kept exactly
as the user left them and committed with the scheduler work:
`home_page.dart` (physics line commented, padding 0),
`categories_view.dart` (grid card changes, still has 2 unused-symbol warnings),
`islamic_header_background.dart` (BlendMode line commented — compiles),
`azan_section.dart` (spacing + stroke width). Nothing was reverted.

## Next steps (in priority order)

1. **Real-device test**: install on a physical phone, mute one prayer and leave
   another on, kill the app, confirm the adhan fires at the right minute with
   sound. Watch for OEM battery killers (Xiaomi/Huawei/Samsung) — may need an
   "ignore battery optimisations" prompt.
2. **iOS** `.caf` sound via Xcode (≤30s `adhan_short.caf` in the Runner bundle,
   then `sound: 'adhan_short.caf'` in `DarwinNotificationDetails`); test on a
   real iPhone. Full-length adhan on iOS needs the app open or Critical Alerts.
3. Decide `SCHEDULE_EXACT_ALARM` vs `USE_EXACT_ALARM` before store submission
   (see §6 above).
4. Delete the dead `lib/features/adhan/` tree + `notifiers.dart` once the new
   stack has been on a device for a while (nothing navigates to it today).
5. Optional: `/refactor` migrations per `.claude/commands/refactor.md`
   (azkar reading feature first), legacy `teal` sweep, iOS over-scroll gap.

## Emulator gotchas seen while testing

- `GeolocatorLocationService` ANRs on the emulator ("waited 20014ms") when no
  location fix exists — set one with `adb -s emulator-5554 emu geo fix <lng>
  <lat>` before testing. Unrelated to the scheduler.
- To force an azan without waiting: `adb root`, then
  `adb shell "date MMDDhhmmYYYY.ss"` to just before a scheduled time
  (`adb shell dumpsys alarm | grep -A2 ScheduledNotificationReceiver` lists
  them). Restore with `adb shell settings put global auto_time 1`.
- Inspect what actually fired:
  `adb shell dumpsys notification --noredact | grep -A30 azan_channel`.

## How to run / test quickly

```bash
flutter run -d emulator-5554 --debug      # cargokit SEVERE error is expected noise
# log check:
#   AzanScheduler: scheduled N azan notifications
# screenshots: adb -s emulator-5554 exec-out screencap -p > shot.png
```
