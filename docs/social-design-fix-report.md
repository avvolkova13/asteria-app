# Social visual correction

## Scope and source

Corrected only new social surfaces and the new astrology tab header. Existing `MainScreen` uses `AppColors.textPrimary`; `profile_flow_ui.dart` supplies the muted purple surfaces, white/muted white text, and orange-gold accent used here. PlayfairDisplay headings and Urbanist body/control text are existing registered app fonts. No assets, backend/API behavior, pagination, idempotency, account ownership fences, global theme, or native configuration were changed by this task.

The reproduced cause was the new raw Material screens inheriting the legacy `AppThemeLight`: lilac scaffold/app bar, black title/icons, zero title spacing, white primary/FAB foreground, and pink secondary selection. A widget regression using the actual app theme failed before the correction (background luminance 0.841 instead of a dark surface).

## Changes

- `lib/features/social/presentation/social_theme.dart` (new): scoped Material theme based on the existing dark Asteria colors and fonts; consistent cards, inputs, gold selected segments/actions, dialogs, sheets, menus, progress, and snackbar colors. Dialog/snackbar helpers explicitly handle callbacks whose State context sits above the scoped scaffold theme.
- `lib/features/social/presentation/social_scaffold.dart` (new): shared scoped theme, scaffold and bottom/side safe area.
- `lib/features/social/presentation/social_status.dart` (new): readable empty/error message with icon and optional explicit retry action.
- `lib/features/social/presentation/social_feed_screen.dart`: scoped scaffold, full-width gold/dark segment control without the Material check mark; theme corrects title spacing, icons, and FAB contrast.
- `lib/features/social/presentation/social_search_screen.dart`: scoped scaffold and spacing between input fields/search action.
- `lib/features/social/presentation/social_profile_screen.dart`: scoped profile and connections screens, Playfair heading, explicit retry status.
- `lib/features/social/presentation/social_post_screen.dart`: scoped post/comment screen, retry status, themed conflict dialog and error snackbar.
- `lib/features/social/presentation/social_editor.dart`: scoped editor and conflict dialog.
- `lib/features/social/presentation/social_notifications_screen.dart`: scoped notification screen.
- `lib/features/social/presentation/social_notification_settings.dart`: scoped settings screen and explicit retry status.
- `lib/features/social/presentation/social_blocked_screen.dart`: scoped blocked users screen.
- `lib/features/social/presentation/social_actions.dart`: themed delete/report dialogs and snackbars.
- `lib/features/social/presentation/pending_create_guard.dart`: themed pending-create leave dialog; guard behavior retained.
- `lib/features/social/presentation/social_paged_list.dart`: readable empty/error states and bottom clearance for the compose FAB; load-more/retry key and pagination behavior retained.
- `lib/features/social/presentation/astrology_screen.dart`: dark header with gold selected label/indicator, muted-white inactive label, Urbanist typography. Main/Personal children retain their existing inherited theme.
- `test/features/social/social_design_test.dart` (new): app-theme contrast, geometry, compact Russian screen, and overlay regressions.

`SocialPostCard` and `SocialImage` inherit the scoped theme without implementation changes.

## Impact evidence

GitNexus upstream impact was requested for SocialFeedScreen, AstrologyScreen, SocialSearchScreen, SocialNotificationsScreen, SocialNotificationSettings, SocialBlockedScreen, SocialProfileScreen, SocialConnectionsScreen, SocialEditor, SocialPostScreen, SocialPagedList, PendingCreateGuard, confirmSocialDelete, reportSocial, openSocial and socialAction. All returned target-not-found / UNKNOWN because these new untracked social sources are not in the current index. This is not a zero-risk graph result.

Manual references identify `HomeScreen` as the feed/astrology entry, social navigation via `openSocial`, and the shared action/guard/list widgets as local dependencies of the social screens. No legacy theme, MainScreen, PersonalScreen, home tab bar, routing, data/domain or session implementation was edited. Presentation blast radius is all new social screens plus the astrology header; UI regression testing is required because this intentionally affects every new surface.

## Verification

- `flutter test test/features/social/social_design_test.dart`: 3 passed. Tests use `AppThemeLight.instance.getThemeData(context)`, not Flutter's default theme. Checks include feed title inset >=16px, dark background, >=4.5:1 contrast for title/FAB/retry/selected segment, all nine social surfaces at 320x640 with Russian locale, and readable dialog/sheet surfaces when launched across the local theme boundary.
- `flutter test test/features/social`: 34 passed, including block invalidation, account handling, uncertain create immutability/replay, pagination, images, push and API tests.
- `flutter analyze lib/features/social test/features/social`: no issues.
- `ASTERIA_BACKEND_PATH=/Users/anton/Finext/asteria/asteria-back/.worktrees/social GMKT22_BACKEND=/Users/anton/Finext/asteria/asteria-back flutter test`: **835 passed**. The initial run without these existing test overrides had one missing sibling-backend path failure and four skipped cross-repository checks; supplying the intended checkout locations resolved the fixture path and exercised the complete suite. Log: `/tmp/asteria-social-design-full-test.log`.
- `flutter analyze`: 107 informational findings in existing non-social files, no errors/warnings and no social findings. Log: `/tmp/asteria-social-design-analyze.log`.

- `flutter build ios --simulator`: passed; Xcode build 11.2s, artifact `build/ios/iphonesimulator/Runner.app`. Log: `/tmp/asteria-social-design-ios-build.log`.

Parent installed the final build on iPhone 17 Pro Simulator and visually inspected the feed, people search and post editor against the existing Astrology screen. Dark background, registered typefaces, title insets, input surfaces, gold selected tabs/actions and visible compose icon now match the established app palette. Backend deployment is being verified separately; no feed success was inferred from mocked widget tests.

Android debug APK also rebuilt successfully after the correction (`/tmp/asteria-social-design-android-build.log`, Gradle 15.0s). Independent review accepted the scoped theme, overlay handling and preservation of legacy child screen themes.
