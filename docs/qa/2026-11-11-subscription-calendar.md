# Subscription and lunar-calendar refinement

## Scope and design evidence

- Figma file `iRwq5h8Hi7qqhuFLJ2iEtg`, subscription frames `4237:29473` and `5745:10567`: large period heading, price below, right selection indicator, highlighted selected plan, separate purchase action.
- Adapted to the approved shared glass/clay cards and existing typography/tokens. Store/API prices remain authoritative; mockup bonus coins, discounts and free trials were not added.
- Shared subscription crystal has larger layout space and optical compensation for transparent image margins. Text remains in its own row column.
- Calendar order: daily context → month grid → sphere selection/recommendations → date planning → saved plans. No planning/history block interrupts the first daily context.

## Variants checked

- iPhone 16 / iOS 18.2 simulator: inactive subscription, loaded real ArcPay weekly/monthly/yearly prices, unselected and selected plan, selecting a different plan without opening checkout; crystal placement; lunar first viewport; scrolling to lower planning/history.
- Widget/integration tests: native purchase selection followed by confirmation, success/cancellation/pending/failure and restore; ArcPay initial purchase and active-PRO extension with return to originating feature; calendar sphere/date selection, missing remote recommendations, comparison across months, saving and returning to saved plans.
- Shared provider variants inspected: Apple/Google product cards retain native localized prices and Google trial/renewal terms; ArcPay one-time and recurring lists use the same visual selection component. No real payment was made. Active-PRO geometry was exercised in widget tests; the simulator account has inactive PRO.
- Reduced motion: selection transition duration is zero when system animations are disabled. Existing shared entrance, tap and haptic components are reused.

## Verification and limitations

- Targeted analyzer: no issues in edited screen/test files.
- Subscription/calendar targeted test suite passes; active ArcPay extension has its own regression coverage.
- Full parallel suite: 939 passed, 4 skipped, one failure in the unchanged Apple coordinator test `native future hangs: deadline stops spinner, receipt is processed, duplicate buy remains blocked` (`api.reconciled` expected 1, got 0). The Apple-coordinator file passed separately. This timing failure remains an explicit limitation; no payment-coordinator production code was changed.
- Calendar reordering and payment-flow review used one bounded independent agent; final native inspection and integration were performed by the main agent.
- Native screenshots are in `/private/tmp/subscription-ui/` and are temporary inspection artifacts.
