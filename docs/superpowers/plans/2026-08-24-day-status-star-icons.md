# Day Status Star Icons Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace legacy day-status smiley icons with the exact Figma star assets everywhere the favorable, neutral, and unfavorable day status is shown.

**Architecture:** Move `DayStatus` into a standalone presentation model, centralize numeric classification and asset mapping, and render all status icons through one reusable widget. Keep calendar missing-data behavior owned by callers so absent calendar content does not become a neutral icon in the month grid.

**Tech Stack:** Flutter/Dart, `flutter_test`, existing app localization and UI kit, existing `assets/icons/` asset registration.

**Spec:** `docs/superpowers/specs/2026-08-24-day-status-star-icons-design.md`

## Global Constraints

- Exact production assets are `assets/icons/day_status_favorable_star.png`, `assets/icons/day_status_neutral_star.png`, and `assets/icons/day_status_unfavorable_star.png`.
- Exact source PNG SHA-256 values are favorable `3cf197c7b610f0ba93b05f251df5096daaaab5f983dabafb987865ae87971b31`, neutral `a3839a269be62303cffa20e84e81e43f726846554b0dec306e04edd7ee0f24c2`, unfavorable `6ef6dcb3503e816e1e409c28bc49f83ea614947ab12fe3df8e9d8ea1321ea42d`.
- Business classification remains `> 0 => favorable`, `== 0 => neutral`, `< 0 => unfavorable`.
- Month grid day with no calendar data shows no status icon.
- Selected day without calendar data and Moon Phase fallback remain neutral.
- Status icon sizes remain 14 logical px in the month grid and phase strip, and 25 logical px in the legend and status badge.
- `assets/icons/good_day_icon.png`, `assets/icons/neutral_day_icon.png`, and `assets/icons/bad_day_icon.png` must not remain referenced in production Dart code or tests.
- Do not touch or stage unrelated `ios/Podfile` changes.

---

## File Structure

- Create `lib/features/home/presentation/models/day_status.dart`: owns `enum DayStatus` and sign-based factory `DayStatus.fromValue(int value)`.
- Create `lib/features/home/presentation/models/day_status_assets.dart`: owns exhaustive `DayStatus` to asset-path mapping.
- Create `lib/features/home/presentation/widgets/day_status_icon.dart`: owns image rendering, sizing, decode cache sizing, and semantics behavior.
- Modify `lib/features/home/presentation/cubit/moon_screen_state.dart`: imports `DayStatus` from the new model instead of defining it locally.
- Modify `lib/features/home/presentation/cubit/moon_screen_cubit.dart`: uses `DayStatus.fromValue`.
- Modify status consumers: `calendar_statuses_widget.dart`, `moon_calendar_widget.dart`, `moon_phase_widget.dart`, `moon_design_tokens.dart`, `advice_widget.dart`, `moon_screen.dart`, and tests that import `DayStatus`.
- Copy exact source PNGs from `docs/superpowers/specs/assets/2026-08-24-day-status-stars/` to `assets/icons/`.
- Delete legacy PNGs from `assets/icons/` after every reference is migrated.

## Task 1: Shared DayStatus Model, Assets, and Renderer

**Files:**
- Create: `lib/features/home/presentation/models/day_status.dart`
- Create: `lib/features/home/presentation/models/day_status_assets.dart`
- Create: `lib/features/home/presentation/widgets/day_status_icon.dart`
- Create: `test/features/home/presentation/models/day_status_test.dart`
- Create: `test/features/home/presentation/widgets/day_status_icon_test.dart`
- Modify: `lib/features/home/presentation/cubit/moon_screen_state.dart`
- Modify: `lib/features/home/presentation/models/day_status_advice.dart`
- Modify: `test/features/home/presentation/models/day_status_advice_test.dart`

**Interfaces:**
- Produces: `enum DayStatus { favorable, unfavorable, neutral }`
- Produces: `factory DayStatus.fromValue(int value)`
- Produces: `extension DayStatusAssets on DayStatus { String get iconAssetPath; }`
- Produces: `class DayStatusIcon extends StatelessWidget { const DayStatusIcon({super.key, required DayStatus status, required double size, String? semanticLabel, bool excludeFromSemantics = false}); }`

- [ ] **Step 1: Write failing model tests**

```dart
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/models/day_status_assets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifies positive zero and negative values by sign', () {
    expect(DayStatus.fromValue(3), DayStatus.favorable);
    expect(DayStatus.fromValue(0), DayStatus.neutral);
    expect(DayStatus.fromValue(-2), DayStatus.unfavorable);
  });

  test('maps each status to the new Figma star asset only', () {
    expect(DayStatus.favorable.iconAssetPath, 'assets/icons/day_status_favorable_star.png');
    expect(DayStatus.neutral.iconAssetPath, 'assets/icons/day_status_neutral_star.png');
    expect(DayStatus.unfavorable.iconAssetPath, 'assets/icons/day_status_unfavorable_star.png');
    expect(
      DayStatus.values.map((status) => status.iconAssetPath),
      isNot(contains(anyOf(
        'assets/icons/good_day_icon.png',
        'assets/icons/neutral_day_icon.png',
        'assets/icons/bad_day_icon.png',
      ))),
    );
  });
}
```

- [ ] **Step 2: Run tests to verify RED**

Run: `flutter test test/features/home/presentation/models/day_status_test.dart`
Expected: FAIL because `day_status.dart` and `day_status_assets.dart` do not exist.

- [ ] **Step 3: Implement shared model and asset mapping**

```dart
enum DayStatus {
  favorable,
  unfavorable,
  neutral;

  factory DayStatus.fromValue(int value) {
    if (value > 0) return DayStatus.favorable;
    if (value < 0) return DayStatus.unfavorable;
    return DayStatus.neutral;
  }
}
```

```dart
import 'package:asteria_app/features/home/presentation/models/day_status.dart';

extension DayStatusAssets on DayStatus {
  String get iconAssetPath {
    return switch (this) {
      DayStatus.favorable => 'assets/icons/day_status_favorable_star.png',
      DayStatus.neutral => 'assets/icons/day_status_neutral_star.png',
      DayStatus.unfavorable => 'assets/icons/day_status_unfavorable_star.png',
    };
  }
}
```

- [ ] **Step 4: Move imports off `moon_screen_state.dart` enum**

Remove the enum declaration from `moon_screen_state.dart`, import `day_status.dart`, and update `day_status_advice.dart` plus its test to import `day_status.dart`.

- [ ] **Step 5: Run model tests to verify GREEN**

Run: `flutter test test/features/home/presentation/models/day_status_test.dart test/features/home/presentation/models/day_status_advice_test.dart`
Expected: PASS.

- [ ] **Step 6: Write failing renderer widget tests**

```dart
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders selected status asset at requested size', (tester) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      home: DayStatusIcon(status: DayStatus.favorable, size: 14),
    ));

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
    final image = tester.widget<Image>(find.byType(Image));
    final asset = image.image as ResizeImage;
    final inner = asset.imageProvider as AssetImage;

    expect(sizedBox.width, 14);
    expect(sizedBox.height, 14);
    expect(image.width, 14);
    expect(image.height, 14);
    expect(image.fit, BoxFit.contain);
    expect(asset.width, 42);
    expect(asset.height, 42);
    expect(inner.assetName, 'assets/icons/day_status_favorable_star.png');
  });

  testWidgets('supports explicit semantics and exclusion', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Column(
        children: [
          DayStatusIcon(status: DayStatus.neutral, size: 25, semanticLabel: 'Нейтральный день'),
          DayStatusIcon(status: DayStatus.unfavorable, size: 25, excludeFromSemantics: true),
        ],
      ),
    ));

    expect(find.bySemanticsLabel('Нейтральный день'), findsOneWidget);
    expect(find.bySemanticsLabel('Неблагоприятный день'), findsNothing);
  });
}
```

- [ ] **Step 7: Run renderer tests to verify RED**

Run: `flutter test test/features/home/presentation/widgets/day_status_icon_test.dart`
Expected: FAIL because `DayStatusIcon` does not exist.

- [ ] **Step 8: Implement `DayStatusIcon`**

Use `Image.asset(status.iconAssetPath, width: size, height: size, fit: BoxFit.contain, cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(), cacheHeight: same)` inside a fixed `SizedBox`. If `excludeFromSemantics` is true, wrap the image in `ExcludeSemantics`; otherwise pass `semanticLabel` to `Image.asset`.

- [ ] **Step 9: Run Task 1 tests**

Run: `flutter test test/features/home/presentation/models/day_status_test.dart test/features/home/presentation/models/day_status_advice_test.dart test/features/home/presentation/widgets/day_status_icon_test.dart`
Expected: PASS.

- [ ] **Step 10: Commit**

```bash
git add lib/features/home/presentation/models/day_status.dart lib/features/home/presentation/models/day_status_assets.dart lib/features/home/presentation/widgets/day_status_icon.dart lib/features/home/presentation/cubit/moon_screen_state.dart lib/features/home/presentation/models/day_status_advice.dart test/features/home/presentation/models/day_status_test.dart test/features/home/presentation/models/day_status_advice_test.dart test/features/home/presentation/widgets/day_status_icon_test.dart
git commit -m "feat: add shared day status icon model"
```

## Task 2: Cubit Classification Refactor

**Files:**
- Modify: `lib/features/home/presentation/cubit/moon_screen_cubit.dart`
- Modify: `test/features/home/presentation/cubit/moon_screen_cubit_test.dart`

**Interfaces:**
- Consumes: `DayStatus.fromValue(int value)` from Task 1.
- Produces: `MoonScreenCubit` no longer duplicates sign classification.

- [ ] **Step 1: Write failing focused cubit test**

Add a test to `moon_screen_cubit_test.dart` proving that a missing selected lunar day remains neutral while generated month statuses include only dates that have data:

```dart
test('keeps missing selected day neutral without adding missing month statuses', () {
  final provider = _FakeContentProvider(days: []);
  final cubit = MoonScreenCubit(contentProvider: provider);
  final date = DateTime(2026, 7, 27);

  cubit.selectDate(date);
  cubit.loadDayStatuses(date);

  expect(cubit.state.selectedDayStatus, DayStatus.neutral);
  expect(cubit.state.dayStatuses, isEmpty);
});
```

- [ ] **Step 2: Run cubit test to verify RED or current-coverage PASS**

Run: `flutter test test/features/home/presentation/cubit/moon_screen_cubit_test.dart`
Expected: If this exact behavior is already covered, it may PASS; record that the test locks existing missing-data behavior before refactor. Otherwise, fix only the test harness until it fails for a real missing-data regression.

- [ ] **Step 3: Replace local sign classification**

In `_getStatusForSphere`, keep existing sphere selection logic, then return `DayStatus.fromValue(statusValue)`. Keep `_getStatusForLunarDay(null, sphere)` returning `DayStatus.neutral`.

- [ ] **Step 4: Run cubit tests**

Run: `flutter test test/features/home/presentation/cubit/moon_screen_cubit_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/presentation/cubit/moon_screen_cubit.dart test/features/home/presentation/cubit/moon_screen_cubit_test.dart
git commit -m "refactor: centralize moon calendar day status classification"
```

## Task 3: Month Calendar and Legend Migration

**Files:**
- Modify: `lib/features/home/presentation/widgets/calendar_statuses_widget.dart`
- Modify: `lib/features/home/presentation/widgets/moon_calendar_widget.dart`
- Create: `test/features/home/presentation/widgets/calendar_statuses_widget_test.dart`
- Create or modify: `test/features/home/presentation/widgets/moon_calendar_widget_test.dart`

**Interfaces:**
- Consumes: `DayStatusIcon` and `DayStatus.iconAssetPath`.
- Produces: month grid and legend use the same star renderer.

- [ ] **Step 1: Write failing legend widget test**

Render `CalendarStatusesWidget` in a localized `MaterialApp` and assert the visible `Image` asset names contain the three new star paths and do not contain the three old smiley paths. Also assert each `Image.width` and `Image.height` is `25`.

- [ ] **Step 2: Write failing calendar widget tests**

Render `MoonCalendarWidget` with a fake `MoonScreenCubit` state containing three in-month statuses and one missing in-month date. Assert the `Image` asset set contains all three new star paths, does not contain old smiley paths, and that no neutral image is created for the missing date count. Add a separate state with `primaryPhaseDates` containing a status date and assert the 5x5 primary phase marker still renders in the same cell by finding a `Container` with circular shape and `width == 5`, `height == 5`.

- [ ] **Step 3: Run widget tests to verify RED**

Run: `flutter test test/features/home/presentation/widgets/calendar_statuses_widget_test.dart test/features/home/presentation/widgets/moon_calendar_widget_test.dart`
Expected: FAIL because widgets still use old asset paths or tests do not exist yet.

- [ ] **Step 4: Migrate legend**

Change `_CalendarStatusItem` to accept `DayStatus status` instead of `String iconPath`. Render `DayStatusIcon(status: status, size: 25, excludeFromSemantics: true)` beside the existing localized title.

- [ ] **Step 5: Migrate month grid indicators**

Import `day_status_icon.dart`, replace `Image.asset(_getStatusIconPath(status), width: 14, height: 14)` with `DayStatusIcon(status: status, size: 14, semanticLabel: _statusSemanticsLabel(context, status))`, and delete `_getStatusIconPath`.

- [ ] **Step 6: Add status to calendar semantics overlay**

For each in-month overlay day, if `state.dayStatuses[normalizedDay]` exists, append the localized status text from `context.l10n.dayFavorable/dayNeutral/dayUnfavorable` with newlines replaced by spaces to the date label. Keep outside days label as date-only and keep `onTap` behavior unchanged.

- [ ] **Step 7: Run Task 3 tests**

Run: `flutter test test/features/home/presentation/widgets/calendar_statuses_widget_test.dart test/features/home/presentation/widgets/moon_calendar_widget_test.dart`
Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/home/presentation/widgets/calendar_statuses_widget.dart lib/features/home/presentation/widgets/moon_calendar_widget.dart test/features/home/presentation/widgets/calendar_statuses_widget_test.dart test/features/home/presentation/widgets/moon_calendar_widget_test.dart
git commit -m "feat: use star day status icons in lunar calendar"
```

## Task 4: Moon Phase Strip and Badge Migration

**Files:**
- Modify: `lib/features/home/presentation/widgets/moon_phase_widget.dart`
- Modify: `test/features/home/presentation/widgets/moon_phase_widget_test.dart`

**Interfaces:**
- Consumes: `DayStatus`, `DayStatus.fromValue`, `DayStatusIcon`, and existing `DayStatusAdvice.title(BuildContext)`.
- Produces: no `_MoonDayStatus`, no local status asset switch, same Moon Phase fallback behavior.

- [ ] **Step 1: Write failing Moon Phase status tests**

Extend `moon_phase_widget_test.dart` with fixture calendar days for favorable, neutral, and unfavorable `categoryStatus` values around the selected date. Assert the day strip renders all three new star asset paths at `14x14`, the status badge renders the selected date's new star at `25x25`, and old smiley paths are absent.

- [ ] **Step 2: Write failing fallback test**

Add a test where `getLunarCalendarDayByDate` returns null for the selected Moon Phase date. Assert the status badge text is `Нейтральный день` and the badge icon asset is `assets/icons/day_status_neutral_star.png`.

- [ ] **Step 3: Run Moon Phase tests to verify RED**

Run: `flutter test test/features/home/presentation/widgets/moon_phase_widget_test.dart`
Expected: FAIL because Moon Phase still uses `_MoonDayStatus` and old smiley paths.

- [ ] **Step 4: Replace `_MoonDayStatus` with `DayStatus`**

Change `_statusForDate`, `_MoonDayTile.status`, `_MoonPhaseCard._statusForMoonPhase`, and `_StatusChip.status` to use `DayStatus`. Use `DayStatus.fromValue(lunarDay?.content.categoryStatus ?? 0)` for Moon Phase fallback.

- [ ] **Step 5: Render strip and badge through `DayStatusIcon`**

In `_MoonDayTile`, replace `Image.asset(status.iconPath, width: 14, height: 14, fit: BoxFit.contain)` with `DayStatusIcon(status: status, size: 14, semanticLabel: status.title(context).replaceAll('\n', ' '))`. In `_StatusChip`, keep the existing text and replace the trailing image with `DayStatusIcon(status: status, size: 25, excludeFromSemantics: true)`.

- [ ] **Step 6: Remove private Moon Phase presentation type**

Delete `enum _MoonDayStatus` and `extension _MoonDayStatusPresentation`. Use existing public `DayStatusAdvice.title(context)` for badge text.

- [ ] **Step 7: Run Task 4 tests**

Run: `flutter test test/features/home/presentation/widgets/moon_phase_widget_test.dart`
Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/home/presentation/widgets/moon_phase_widget.dart test/features/home/presentation/widgets/moon_phase_widget_test.dart
git commit -m "feat: use star day status icons in moon phase"
```

## Task 5: Asset Promotion, Legacy Cleanup, and Regression Checks

**Files:**
- Create: `assets/icons/day_status_favorable_star.png`
- Create: `assets/icons/day_status_neutral_star.png`
- Create: `assets/icons/day_status_unfavorable_star.png`
- Delete: `assets/icons/good_day_icon.png`
- Delete: `assets/icons/neutral_day_icon.png`
- Delete: `assets/icons/bad_day_icon.png`
- Modify: `integration_test/lunar_calendar_distribution_test.dart`

**Interfaces:**
- Consumes: all production code paths now point to new star asset paths.
- Produces: repository has no legacy status-smiley asset references.

- [ ] **Step 1: Write failing integration expectation update**

Change `_visibleStatusAssets` expectations in `integration_test/lunar_calendar_distribution_test.dart` to require the three new star paths and reject the three old paths:

```dart
expect(
  _visibleStatusAssets(tester),
  containsAll(const {
    'assets/icons/day_status_favorable_star.png',
    'assets/icons/day_status_neutral_star.png',
    'assets/icons/day_status_unfavorable_star.png',
  }),
);
expect(
  _visibleStatusAssets(tester),
  isNot(contains(anyOf(
    'assets/icons/good_day_icon.png',
    'assets/icons/neutral_day_icon.png',
    'assets/icons/bad_day_icon.png',
  ))),
);
```

- [ ] **Step 2: Run integration test to verify RED or environment boundary**

Run: `flutter test integration_test/lunar_calendar_distribution_test.dart`
Expected before asset promotion: may FAIL due missing files or backend/environment. Record exact result; if backend is unavailable, continue with static and widget verification and report integration boundary honestly.

- [ ] **Step 3: Promote exact Figma assets**

Copy:

```bash
cp docs/superpowers/specs/assets/2026-08-24-day-status-stars/day_status_favorable_star.png assets/icons/day_status_favorable_star.png
cp docs/superpowers/specs/assets/2026-08-24-day-status-stars/day_status_neutral_star.png assets/icons/day_status_neutral_star.png
cp docs/superpowers/specs/assets/2026-08-24-day-status-stars/day_status_unfavorable_star.png assets/icons/day_status_unfavorable_star.png
```

Then verify:

```bash
shasum -a 256 assets/icons/day_status_*_star.png
```

Expected hashes match the Global Constraints.

- [ ] **Step 4: Delete legacy status smiley assets**

Remove exactly:

```bash
rm assets/icons/good_day_icon.png assets/icons/neutral_day_icon.png assets/icons/bad_day_icon.png
```

- [ ] **Step 5: Run static legacy-reference scan**

Run: `rg -n "good_day_icon|neutral_day_icon|bad_day_icon|_MoonDayStatus|assets/icons/day_status_.*_star.png" lib test integration_test`
Expected: old names and `_MoonDayStatus` have zero hits; new paths appear only in shared asset mapping and tests.

- [ ] **Step 6: Decode promoted PNGs**

Run a Flutter test or Dart image decode check that loads all three `AssetImage` files through the test asset bundle. Expected: no asset or decode exceptions.

- [ ] **Step 7: Run targeted tests**

Run:

```bash
flutter test test/features/home/presentation/models/day_status_test.dart test/features/home/presentation/models/day_status_advice_test.dart test/features/home/presentation/widgets/day_status_icon_test.dart test/features/home/presentation/cubit/moon_screen_cubit_test.dart test/features/home/presentation/widgets/calendar_statuses_widget_test.dart test/features/home/presentation/widgets/moon_calendar_widget_test.dart test/features/home/presentation/widgets/moon_phase_widget_test.dart
```

Expected: PASS.

- [ ] **Step 8: Run broad verification**

Run: `flutter analyze`
Expected: PASS.

Run: `flutter test`
Expected: PASS.

Run: `flutter test integration_test/lunar_calendar_distribution_test.dart`
Expected: PASS if backend/runtime configuration is available; otherwise record exact blocker separately from unit/widget success.

- [ ] **Step 9: Commit**

```bash
git add assets/icons/day_status_favorable_star.png assets/icons/day_status_neutral_star.png assets/icons/day_status_unfavorable_star.png assets/icons/good_day_icon.png assets/icons/neutral_day_icon.png assets/icons/bad_day_icon.png integration_test/lunar_calendar_distribution_test.dart
git commit -m "chore: replace legacy day status smiley assets"
```

## Self-Review

- Spec coverage: Tasks 1-5 cover shared model, centralized asset mapping, renderer, all four UI surfaces, accessibility semantics, exact asset promotion, legacy deletion, integration update, and verification.
- Placeholder scan: No unfinished placeholder markers or unspecified test steps remain.
- Type consistency: `DayStatus`, `DayStatus.fromValue`, `DayStatus.iconAssetPath`, and `DayStatusIcon` signatures are consistent across tasks.
