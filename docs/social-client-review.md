# Independent Flutter social review — 2026-09-18

Verdict after fix round 1 and terminal-rejection correction: **ACCEPT for local implementation scope. No open Important/Critical findings.** Production deployment, authenticated visual E2E and real-device APNs/FCM delivery remain separate acceptance boundaries.

Reviewed the original tracked/untracked package against backend `docs/social-implementation.md`, then inspected the current source directly for the fixes, durable pending-create journal, account-deletion cleanup and nested navigation. GitNexus tracked-change analysis did not cover the new unindexed feature, so direct source review and focused reproductions were authoritative.

## Original findings — closed

1. **Cold-start notification target stranded after Home readiness.** Native initialization now drains the target immediately through the authentication/Home gate, before waiting for registration. A generation captured before native initialization and permission/token requests prevents completion from an ended session resurrecting an old target. The original independent `/tmp/social_review_cold_start_test.dart` now passes. Repository tests also pass for initialization completing after logout/account replacement.

2. **Blocked comment author remained visible after returning from profile.** Comment-profile return now immediately discards the post/comments snapshot and refetches it; a removed reply target is cleared. Parent-comment navigation, search results, connections and nested profile return paths now refresh. The original independent `/tmp/social_review_block_test.dart` now passes, as does the repository regression test. Backend access checks remain authoritative; no authorization bypass was identified.

3. **Changed drafts reused a committed idempotency key after a lost response.** Posts, replies and reports now persist the exact original command before sending. Post file IDs and reply parent IDs are preserved with text/key. Unknown outcomes keep the command and lock mutations; leaving/reopening restores it, and retry uses the original payload. A subsequent 401 does not discard earlier uncertainty. The journal is partitioned by account, operation and target; successful identity deletion clears that account's journal via the existing auth lifecycle. UI account checks and a post-write ownership check prevent sending under a changed account. Reports use the same journal/replay mechanism.

## Additional recovery issue found and closed

The first journal implementation retained `409 invalid_file` forever, locking all new-post composition when a draft attachment had expired or been removed. Both first-attempt rejection and rejection after an earlier unknown outcome were independently reproduced in `/tmp/social_review_terminal_file_test.dart`.

The final code now releases only the exact `409 invalid_file` / `409 evidence_unavailable` terminal cases, including after prior uncertainty. This is justified by backend ordering: committed-command lookup precedes the transaction operations emitting these codes, so a committed command would return its stored result instead. Auth failures and generic 409 responses are not generalized into no-commit evidence. Both independent terminal-file tests now pass, and the prior-uncertainty → 401 preservation test still passes.

## Independent verification

Focused reviewer executions, without rerunning the full suite or native builds:

- Original independent cold-start/block reproductions plus pending-create contract tests: 7 passed.
- Repository cold-start generation, blocked-content return and uncertain-create UI tests passed (5 tests; the separate terminal-file tests failed before correction, as expected).
- Independent journal-write-failure/account-switch-during-write tests plus the existing auth-session suite, including identity-delete callback: 10 passed. A failed durable write sends nothing; an account change while saving retains only the original owner's command and sends nothing.
- After the terminal-code correction, independent terminal-file tests plus pending-create contract tests: 7 passed. Covers exact post/reply/report replay, reconstructed store/reopened API, account partitioning, and retained ambiguity after 401.

The implementer/root owns final full-suite and native-build verification; this review does not substitute focused tests for those checks. The previously identified Xcode localization resource-ID collision was corrected and is not an open finding.

## Scope assessment and limits

DTOs/API paths align with the approved contract, including nullable tombstones, opaque notification IDs, protected image bytes, full-date search and explicit public-profile fields. Feed/Astrology/Moon/Profile integration retains the existing Home/Personal components and Anakra. Post-only likes, version conflicts, 350 graphemes, two attachments and image-only posts are implemented. Analytics uses fixed allowlisted actions without text, names, birth dates, search terms, media URLs or entity IDs. Existing JWT identity remains authoritative; no social flags or Firebase identity/storage were introduced.

Inspected pagination generation fencing/ID deduplication, image replacement and resume access checks, serialized device registration/logout removal, and durable pending-command ownership. No additional Important/Critical issue was found in these paths. This is evidence-bounded review, not proof against every concurrency or platform lifecycle sequence.

Authenticated deployed visual E2E, real-device push permission/token/receipt/tap-through and real Slack delivery remain unverified external boundaries. Reviewer made no production-source changes, commits, pushes or deployments; only this report and temporary focused test files were written.
