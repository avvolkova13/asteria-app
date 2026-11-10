# Social client implementation

Worktree: `asteria-app/.worktrees/social`, branch `codex/social`. No commit, push, deployment, social feature flag, or Firebase identity/database/storage dependency was introduced.

## Implemented

- Authenticated landing is Feed, default Interesting, with Following. Four bottom tabs are Feed / Astrology / Moon / Profile; Astrology contains the existing Home and Personal pages. Existing Anakra entry remains. Nested Astrology analytics preserve the existing visibility guards for card impressions.
- Typed DTOs and API cover public profiles, normalized-name/full-date search, paginated feed and connections, follows, blocks and blocked-users list, reporting, posts, post likes, comments/replies, notifications/read counts/preferences and devices. Uses the existing refreshing `AuthSessionService` and the established app-key plus `X-Asteria-User-Token` convention. Request/response bodies and tokens are not logged by this client. Results are rejected after account switches.
- Post editor supports 350 extended grapheme clusters and zero-to-two attachments, including image-only posts. Gallery picker checks the 10 MB client limit; server performs format/dimension validation and processing. Processing is polled with a bound, failed uploads can be retried, and removals clean unattached drafts. Missing existing images remain placeholders and do not prevent text edits.
- Own post/comment edit/delete, server-version conflict handling that preserves the draft, deliberate latest-version confirmation, parent-comment links, tombstones with nullable author and surviving replies. Idempotency conflicts are kept separate from editable version conflicts.
- Pagination handles loading, retry, empty and refresh states. Pages merge by entity ID, so live score changes cannot duplicate post cards. Comment targets load successive pages and scroll to the target.
- Private images use authenticated byte requests, no public URLs or shared URL cache. Replacement IDs are keyed, `didUpdateWidget` reloads defensively, and new futures clear old snapshots. Foreground resume revalidates access.
- Native APNs bridge on iOS; native Firebase Messaging transport only on Android, with `social` channel, runtime permission, token refresh and foreground/background tap handling. Existing StoreKit bridge retained. Device registration uses a durable installation UUID, current JWT session, old-session DELETE before logout/account replacement, serialized in-flight registration, and native token retirement. Registration errors retry without blocking login.
- Notification taps and validated `asteria://social/posts/{id}?comment_id={id}` URLs wait for authenticated Home before navigation. Backend access remains authoritative if a target has been deleted or blocked.
- In-app notification inbox works without push permission. All notification toggles are editable; blocked-user management is reachable from notification settings.
- App UI strings generated for ru and all five existing English locales. Native `social_push_post`, `social_push_like`, `social_push_comment`, `social_push_reply` resources exist in Android en/ru and iOS en/ru `Localizable.strings`; iOS resources are in the Xcode build phase. Android foreground text selects the same kind-specific resources.
- First-party `social_action` uses a fixed enum and sanitized payload `{feature: social, social_action: ...}`. AppsFlyer projection is `ast_social_action`. No content, names, dates, search terms, media URLs or social entity IDs enter these events. Backend allowlist was coordinated with the backend owner.

## Review corrections

Independent review accepted the final implementation with no open Important/Critical findings; see `social-client-review.md`.

- Cold-start native targets are drained when initialization finishes after Home readiness. Logout/account changes fence late native completions so stale targets cannot return.
- Returning from a nested profile refreshes post/comments, search and connections. Blocked content disappears, removed reply targets clear, and local text drafts/edit versions survive.
- Post, comment/reply and report creation journals the immutable original payload and idempotency key before sending, partitioned by account and operation. An unknown outcome locks content/attachment/parent changes; leaving and reopening restores the original command for exact replay. Potentially committed draft files are retained. Subsequent auth failures preserve uncertainty. Successful account deletion clears only that account's pending commands.
- Exact `409 invalid_file` / `409 evidence_unavailable` responses release pending commands because backend committed-result lookup precedes those rejection paths; generic conflicts/auth errors do not establish this. Unavailable attachment rejection shows a localized recovery explanation. Failed journal writes or account changes while writing prevent network creation.

## Verification

Commands are run from this worktree. Full-suite cross-repository tests use:

```sh
GMKT22_BACKEND=/Users/anton/Finext/asteria/asteria-back \
ASTERIA_BACKEND_PATH=/Users/anton/Finext/asteria/asteria-back/.worktrees/social \
/opt/homebrew/bin/flutter test
```

`GMKT22_BACKEND` is the existing contract-test interpreter location (backend virtualenv); `ASTERIA_BACKEND_PATH` points the AppsFlyer event-contract test at the matching social backend source. Without `GMKT22_BACKEND`, four existing Python-backed payment/analytics contract tests skip in this nested worktree. These four were also exercised with the explicit path.

Final checks on 2026-09-18:

- Full Flutter suite: **832 passed, zero skipped, zero failed** (35 seconds), including the four existing Python-backed contract tests enabled through `GMKT22_BACKEND`.
- Focused social suite: **31 passed**.
- Focused analyze of all changed production Dart files and new tests: **no issues**. Full `flutter analyze`: **107 existing info-level lints**, no warnings/errors, no new social diagnostics; command exits 1 because existing infos are configured as fatal. The unchanged issues are in pre-existing app widgets/extensions/screens.
- iOS debug simulator build: **build succeeded**; all four push keys verified in both en/ru `Runner.app/*/Localizable.strings`. Xcode object IDs checked unique after adding the localized resource group.
- Android debug APK: **build succeeded**, native four-key push resources verified via `aapt2 dump resources`.
- `git diff --check` and native plist/project lint: passed.

Artifacts:

- `/Users/anton/Finext/asteria/asteria-app/.worktrees/social/build/ios/iphonesimulator/Runner.app`
- `/Users/anton/Finext/asteria/asteria-app/.worktrees/social/build/app/outputs/flutter-apk/app-debug.apk`
- APK SHA-256: `55f0b42039073039dec9cc803c37c2d2cb38e28e567a93bccedd9a163e40476d`.

Final logs: `/tmp/social-final-full-tests.log`, `/tmp/social-final-focused-analyze.log`, `/tmp/social-final-analyze.log`, `/tmp/social-final-ios-build.log`, `/tmp/social-final-android-build.log`. Focused social tests: `/tmp/social-round1-final-focused-tests.log`.

Targeted tests cover grapheme bounds; payload/URI validation; nullable tombstones; authenticated search and cursors; account switches; idempotency/version conflict distinction; pagination retries/dedup/comment anchoring; feed default/mode change; editor missing-file retention and draft preservation; image replacement clearing stale bytes; push login gating, late cold-start targets and logout/token rotation races; block return invalidation; persisted immutable create replay after lost responses; editor leave/reopen and account partitioning; ambiguity followed by 401; terminal unavailable-file recovery; identity deletion cleanup; analytics PII filtering. Existing auth, onboarding, startup, monetization, analytics and card-impression tests remain in the full suite.

## External setup and limits

- APNs requires the existing iOS bundle ID `com.toolsafesolutions.asteria` enabled for push, a matching provisioning profile/entitlement and backend APNs credentials/topic/environment. `Runner.entitlements` already has the development entitlement; distribution signing must use the matching production APNs environment. Simulator compile is not real-device receipt verification.
- Android uses the existing `com.finext.asteria` Google Services configuration and native `firebase-messaging:24.1.2`. Backend FCM service-account/project configuration must match the installed app. Neither server credentials nor service-account keys were created or changed here.
- Backend push payload localization contract: APNs `aps.alert.loc-key` and FCM Android `notification.body_loc_key` use `social_push_<kind>`; data carries `notification_id`, `post_id`, optional `comment_id`, `kind`. No text or actor PII is required on the lock screen.
- Real-device push permission/token registration, foreground/background/killed-app receipt and tap-through were not exercised against configured APNs/FCM credentials. Authenticated visual E2E against a deployed social backend was not performed. Builds and widget tests do not prove delivery or production receipt.
- Offline logout cannot prove a server DELETE/revocation succeeded. The client attempts removal before clearing the old session and retires the native token; the backend also removes devices on successful session revocation and validates sessions before dispatch. Server-side revocation still requires network access.
- New social detail screens are currently presented as MaterialPageRoutes from the existing Home route; native/URI pending-target handling is in SocialPushService. The outer application GoRouter and existing payment-link listener remain intact.
- Reference platform documentation: [Apple APNs registration](https://developer.apple.com/documentation/usernotifications/registering-your-app-with-apns), [FCM Android receiving](https://firebase.google.com/docs/cloud-messaging/android/receive-messages).
