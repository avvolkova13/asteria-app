# Post editor — approved Superdesign transfer

Date: 2026-09-21

## Visual target and evidence

- User-approved reference: `/var/folders/wg/h1rz6b3965z0_7g93lc815lc0000gn/T/codex-clipboard-VtUJtw.png`.
- Design: https://p.superdesign.dev/draft/bcf9672e-65bf-4ea9-aaaf-cbea1e5bdc31
- Source capture: `../artifacts/editor-approved-2026-09-21/source-screen.png`.
- Implementation: `../artifacts/editor-approved-2026-09-21/implementation-screen.png`.
- Original device capture: `../artifacts/editor-approved-2026-09-21/implementation-native.png`.
- State: Russian, category Story, the same 120-character example, no attachments, keyboard hidden, enabled Publish. Example remains an unsent draft.
- Source screen: 390 × 844. iPhone 17 Pro implementation: 402 × 874 logical points, captured at 1206 × 2622 and normalized to 402 × 874. Native status bar, Dynamic Island, safe areas and home indicator are device-owned; the mock's drawn chrome was not copied.
- Both source and normalized implementation were opened together in one comparison tool result. Text and controls are readable at this size, so separate magnified crops were not necessary.

## Findings and corrections

No remaining actionable P0/P1/P2 differences in the approved ordinary-post state.

- Typography: Playfair Display title and bundled Arimo body (Arial-compatible); regular text, not the discarded italic treatment. Minor rasterization differences from browser Arial are P3.
- Layout: category, body, counter and attachment action share one compact card; 20-point outer margins, 16-point card radius, bottom-pinned 54-point publish action. Card height was increased by one text line after the first simulator comparison to match the reference proportions.
- Colors: composer background #151017, surface #211B27, 16% white boundary; publish gradient #E6994D / #F3B76A / #E6994D. These tokens are scoped to the editor. Other social screens keep their current background.
- Assets: existing Material outline icons replace the equivalent standard reference icons. No new raster assets or decorative graphics are needed. Minor icon-stroke differences are P3.
- Copy: attachment action is localized as “Добавить фото” / “Add photo”. The reference's hardcoded 114/350 counter is deliberately replaced by the actual 120/350 count. Native safe areas account for the vertical offset from the mock.

## Verification and iteration history

1. Initial implementation compiled after restoring the existing dialog helper import. The first full test run then exposed dropdown overflow on a 320 × 640 viewport at 2× text scale.
2. The category control now allows its selected text to fit available width. Compact-layout and keyboard-position tests passed. The selector width and card height were refined during visual comparison.
3. Final social suite: 150 tests passed. Scoped Flutter analysis: no issues. Simulator debug build succeeded. `git diff --check` passed.
4. Final simulator build installed and launched. Manually checked category selection; ordinary post → poll → ordinary post with text retained; adding a poll question; restoring the draft after restart; image processing to ready state and removing that test attachment. No test post was published.
5. Final software-keyboard state was inspected in the simulator: writing area, attachment action and Publish remain visible. Evidence: `../artifacts/editor-approved-2026-09-21/keyboard-window.png`. Widget tests also verify fixed button position while the poll editor scrolls and at increased text scale.

## Scope and limits

This transfers the approved ordinary-post screen. Existing poll editing, upload, validation, restriction, pending-request and draft behavior remain in place. It does not claim a new approved visual design for the entire poll constructor or new end-to-end production publishing verification. No commit, push, backend change or TestFlight upload was performed.

## Category alignment correction

The user identified a P2 missed in the earlier review: the form-field prefix icon and category label differed vertically by 10 logical pixels, and the expanded dropdown put its arrow too far from a short label. A regression test reproduced this before the fix.

Replaced the category form field with a content-sized popup trigger: icon, flexible single-line label and arrow share a centered row with 8-point gaps and a minimum 44-point touch height. Menu options, inactive-category rules and published-poll locking are unchanged. The 15 targeted editor/poll widget tests pass, including the alignment regression and 2× text scaling; scoped analysis and simulator build pass.

Verified the corrected “Факт” row and opening/selecting its menu on the simulator. Post-fix evidence: `../artifacts/editor-approved-2026-09-21/category-aligned.png`.

final result: passed

## Poll constructor — approved Superdesign transfer, 2026-09-21

Source: `../artifacts/poll-design-2026-09-21/superdesign-final.png`, draft `e9ee8fb8-1cb9-4888-ae40-dec244199714`.
Implementation: `../artifacts/poll-design-2026-09-21/implementation-overview.png`, `implementation-question.png`, `implementation-types.png`, `implementation-settings.png` in that directory. The first two are Flutter-rendered fixture captures using the agreed Russian content; the panels were also opened and captured in the running iOS simulator. Capture harness is saved with the artifacts, outside the committed test suite.

Comparison viewport: 390×844 logical pixels. Source board: 1384×1862, each screen 390×844. Question crop: `source-question.png`; implementation normalized to `question-390.png`. The fixture images have no iOS status bar and contain the test harness debug ribbon; neither occurs as app-owned UI in the simulator. Compare app content rather than the mock's simulated top whitespace. Source and implementation were opened together, including the focused question screen comparison.

Fidelity review:
- Typography: PlayfairDisplay headings, Arimo body/actions; real bundled fonts used. Fixed a test-rendering fallback by explicitly applying Arimo to small composer labels. Standard Material icons remain vector icons; there are no raster assets in this design.
- Layout: 20-point margins, 16-point card inset/radius, compact question list, focused editor, separated answer-key selection, fixed 54-point primary button. Reduced question card height after the initial comparison. Date/settings use compact rows and stack on narrow screens or enlarged text.
- Color: shared approved editor tokens #151017/#211B27, muted #BDB4C2, gold #E6994D/#F3B76A. Native surfaces and bottom panels preserve the plum palette.
- Copy: question types and controls localized in Russian and English. Limits and API payloads preserved. The approved category-arrow correction is applied: arrow follows the label instead of sitting at the card's far edge.
- Deliberate runtime adaptations: date is configured once in the overview rather than duplicated inside privacy settings; question removal/reordering are in the overview menu. Real incomplete drafts disable Save/Publish. Back preserves edits in the existing draft mechanism. Native calendar/time pickers replace the mock's static date.

Iteration history:
1. Initial fixture/native capture: question card and setting rows too tall; reduced minimum text lines and compacted detail rows.
2. Post-fix fixture capture: overview and question content reviewed at 390×844, including matching filled question/options. No actionable P0/P1/P2 visual differences remain. Minor platform icon/typography rasterization and switch-size differences are P3.
3. Compact 320×640, 2× text and keyboard test caught an overflowing type selector; wrapped its text flexibly. Regression passes.

Behavior checks: entering a question then backing out/reopening retains text; changing to multiple choice and selecting multiple correct answers retains keys; changing to text removes incompatible options/keys; privacy persists after dismissing the panel; question move/delete preserves IDs; Save stays reachable with a keyboard and enlarged text. Native simulator verified category selection, overview, focused editor, type sheet, photo-answer state and settings. No production poll was published for verification.

Poll design QA final result: passed

Final validation: `flutter test` — 973 passed; scoped Flutter analysis — no issues; iOS simulator debug build succeeded, installed and launched. Final native capture: `../artifacts/poll-design-2026-09-21/simulator-final.png`. No commit or push performed.

final result: passed

## 2026-09-21 — approved violet/gold palette and category placeholder

- Source: ../artifacts/poll-color-preview/comparison-saturated.png (right-hand screen, 390 × 844); source CSS: ../artifacts/poll-color-preview/build.py.
- Implementation: ../artifacts/poll-color-preview/implementation-overview.png and implementation-question.png; Flutter fixture viewport 390 × 844, rendered at 3× density. Comparison inspected with source, normalized to logical dimensions.
- Scope: color-only transfer onto the previously approved native layout. Purple card gradient, gold section/category text, lilac icons and violet question badges match. No decorative bitmap background.
- Existing native typography, scrolling and system chrome retained. No actionable color-transfer findings.
- Fresh editor starts with no category and a muted localized placeholder; chosen category is gold. Reopened unpublished drafts also require explicit category selection; their text and dormant poll questions are preserved. Published posts and in-flight submissions retain their category. Verified mandatory category validation and transition after selection with widget test.
- Validation: 21 targeted tests passed; social presentation analyzer clean. Full-project analyzer reports existing unrelated lint notices.
- final result: passed

## 2026-09-21 — typography and publication overview fidelity correction

The previous palette-only pass was not a full style-parity check. Rechecked the live approved local reference through the existing Chrome tab (direct tab access works despite empty browser tab listing).

- Live per-element computed styles: ../artifacts/poll-style-audit/computed-publication.json and computed-question.json.
- Reference screenshot: ../artifacts/poll-style-audit/source-overview.png, reference canvas 390×844 CSS px.
- Matching-content Flutter captures: ../artifacts/poll-style-audit/implementation-overview.png and implementation-question.png, 390×844 logical px, 1170×2532 physical px. Fixture explicitly loads Arial and bundled fonts. Native screenshot: ../artifacts/poll-style-audit/simulator-overview.jpg (actual user draft, confirms native font rendering; not a same-content comparison).
- Corrected P2 mismatches: category 14→16 px; question heading 20→18 px; question title line-height 1.4→1.25; explicit zero letter spacing; source font families Arial/Urbanist with bundled Arimo fallback; no ListTile default geometry; 16px card padding and gaps; source Lucide icons; choice-option counts and localized progress; settings values 14px and sufficient width; publish label source color and font. Header/main gap reduced to reference geometry relative to native safe area.
- Native system insets and accessible touch areas retained; exact full-screen pixel identity is not claimed. Android font fallback was not device-verified.
- Overview full-view comparison: text wraps match the approved sample; card colors, type sizes, badges and icons align with measured source. Focused inspection: category alignment, card title/subtitle, settings value wrapping and action typography. No remaining actionable P0/P1/P2 in the corrected publication overview scope.
- Validation: 21 targeted tests passed; social presentation analyzer clean. Real simulator draft opens with placeholder, selecting Poll restores questions; publication not submitted.
- final result: passed

## 2026-09-21 — matched viewport follow-up

Previous full-screen comparison was invalid: fixture omitted safe insets and its regular-only Arial loader did not render bold fallback correctly. This iteration compares the same content at 390×844 with reference-equivalent 56px top and 34px bottom insets, actual Arial regular/bold and bundled Playfair/Urbanist. Browser screenshot ICC profile converted to sRGB before comparison.

- Paired evidence: ../artifacts/poll-style-audit/matched-comparison.png (left live reference, right Flutter fixture; 780×844; each panel 390×844).
- Source screenshot: source-full.png with source-rect.json in that directory. Native fixture: implementation-overview.png (1170×2532, normalized 3×→1×).
- Fixed additional P2 findings: double-counted footer bottom inset (button 24px too high), settings row gap 48→37px and horizontal 4px inset, heading horizontal inset, empty second line reserved for a short poll intro, source back arrow and deadline label.
- Actual card/title/subtitle metrics and line wrapping checked in the pair. Color gradient itself was correct; earlier visual suspicion came from comparing different color profiles. Source JPEG compression and native text rasterization differ; no pixel-identical claim.
- Regression: new rendered-height test verifies short intro consumes less than 40px without hiding saved questions. Targeted layout tests 4 passed; prior 21 editor/poll tests passed. Analyzer clean, simulator build passed.
- final result: passed
