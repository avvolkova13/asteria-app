# Generation loading refresh

## Reference and implementation

- Figma file `iRwq5h8Hi7qqhuFLJ2iEtg`, frames `4313:4983` and `4518:66605`; sphere exported directly from image node `4518:66664` to `assets/images/loading/figma_sphere.png`. No generated replacement, temporary URL or new dependency is used in the app.
- Reused ScenarioSky, shared profile header, Lora headings and existing tokens. The exported image's dark outer edge is feathered with a radial shader mask; the whole sphere/halo makes a slow 24s rotation and 3pt bob.
- One `GenerationLoadingContent` controls all phrase timers/motion. Three-second phrases have a sequential 520ms fade, without overlapping readable text. All phrases reserve their longest scaled text height, so the orb does not jump between phrases.
- Shared full-screen generation view covers Sonnik, compatibility, natal chart, rune/tarot insights and four initial/refresh spread purchase/PRO configurations. Natal direct loading and old inline LoadingBlock consumers reuse the same component. Hidden horoscope implementation also reuses it; feature visibility remains unchanged.
- Neutral operations retain the ordinary loader: auth, account removal, saved-spread fetches, checkout/verification and request-pack purchases. No payment routing, backend request, quota or entitlement logic changed.

## Verification

- Native iPhone 16: actual Sonnik generation overlay shown through local debug service only; checked sphere, background, typography, phrase changes and rotating position, then removed overlay. No dream submitted, spread generated, payment or quota consumption performed.
- Local 7s native recording: `/private/tmp/asteria-loading-preview.mp4`; not included in Git.
- Widget checks: four visible feature types at 320×568 and text scale 1.6; first phrase visible, sphere rotation, subsequent phrase, stable height, immediate dismissal, released timer; Reduce Motion/offstage/background pause and resume; empty/replaced phrases; neutral loader unchanged; underlying input focus removed; no two readable phrases during handoff. Hidden-horoscope guard remains covered.
- Full suite before final phrase-handoff polish: 952 passed, 4 skipped. Final targeted suite after polish and all spread-path connections: 49 passed. Analyzer has no errors/warnings; pre-existing informational lints remain outside this task.
- Independent read-only review identified four untyped spread-generation purchase/PRO configurations; all four were connected before final verification. No remaining high/medium review findings.
- Native paid/PRO generation requests were not executed; those connections were reviewed in code and covered by existing feature-access/purchase tests. No independent user usability study was performed.
