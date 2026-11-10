# План интеграции событий аналитики (Asteria Tracking Events 2.1)

> GMKT-22 (2026-09-10): текущий runtime-контракт описан в
> [gmkt-22-mobile-analytics.md](gmkt-22-mobile-analytics.md). Старые требования
> ниже к отправке всех ast/af событий и клиентской выручки в AppsFlyer исторические.

> **Актуализация 2026-09-02:** пользовательский вход по телефону и смена
> номера удалены. Упоминания phone-auth ниже сохранены только как исторический
> контекст исходного аудита и не описывают текущий runtime.

**Дата:** 2026-05-11
**Базовый коммит:** main@9fb397e
**Источник спеки:** `.claude/Asteria - Tracking Events 2.1 Final for Alex.xlsx` (листы: `Events List`, `P0 AppsFlyer Events`, `P1 Raw Detail Events`, `Parameters Dictionary`, `Dictionaries`, `Do Not Send`, `Acceptance`, `Dashboards`, `Code Example`)
**Owner спеки:** Alex / development, дата спеки 2026-05-07
**Текущий централизованный модуль аналитики:** `lib/core/analytics/` (введён коммитом `9cf2b89 AST-71 / feat(analytics): Introduce centralized event parameters and feature names`)

---

## 0. Summary

| Метрика | Значение |
|---|---|
| Всего событий в xlsx | **102** (97 P0 + 5 P1) |
| ✅ Уже реализовано как ast_* | **0** |
| 🟡 Реализован канонический эквивалент, нужно добавить ast_* alias + параметры | **30** |
| ❌ Полностью отсутствует | **72** |
| ❓ Требует решения от продакта (см. §11) | **7** |

**Ключевой вывод:** в кодовой базе уже отправляется ~40 уникальных событий через `AnalyticsFacade`, но **ни одно** не соответствует новой ast_* конвенции из спеки 2.1. Спека требует:

1. **Новый префикс `ast_*`** на всех 97 P0-событиях. Сейчас в коде префиксов нет (`tarot_card_view`, `compatibility_paywall_view`), а legacy события используют `af_*`.
2. **Параметр `canonical_event`** на каждом событии (адаптер маппит ast_* → canonical_event). Сейчас полностью отсутствует.
3. **Новые обязательные параметры**: `origin_surface`, `offer_type`, `payment_type`, `payment_provider`, `funnel_type`, `entry_surface` и др. — большинства нет в `EventParams`.
4. **Revenue rule:** ровно один `*_purchase_success` per транзакция содержит `af_revenue` + `af_currency`. Сейчас revenue размазан между `af_coins_purchase`, `af_purchase` (в `payments_screen.dart` и `user_provider.dart`) — есть риск двойного учёта.
5. **Запрет PII:** телефон, имя, точная дата/место рождения, текст сна, текст сообщения Анакры, partner names, payment payload — не отправлять. Заменять на boolean/band-параметры. Сейчас, по результатам сканирования, PII не отправляется, но это нужно подтвердить ревью на этапе имплементации.

**Рекомендованный подход к имплементации (см. §10):** ввести новый слой `ProductAnalyticsService` поверх существующего `AnalyticsFacade`, который инкапсулирует ast_* события, канонический маппинг и обязательные параметры. Это позволит:
- Не ломать существующие дашборды (`af_*` события остаются).
- Сосредоточить ast_* логику в одном месте (типобезопасные методы вроде `trackCoinPurchaseSuccess(...)`).
- Адаптер автоматически проставляет `canonical_event` и `funnel_type` где это inferable — UI их не передаёт.

---

## 1. Текущее состояние аналитики

### 1.1 Архитектура модуля

```
lib/core/analytics/
├── analytics_facade.dart           # AnalyticsFacade — единая точка входа
│                                     методы: trackEvent, trackAppOpen,
│                                     trackFunnelStep, trackPaywallView,
│                                     trackPurchaseSuccess, trackPurchaseFailed
├── analytics_events.dart           # AnalyticsEvents — константы имён событий
├── event_params.dart               # EventParams — константы имён параметров
├── feature_names.dart              # enum FeatureName + eventValue mapping
├── analytics_route_observer.dart   # GoRouter observer (auto screen_view)
└── attribution/                    # AttributionService, AttributionSnapshot
```

### 1.2 Что уже автоматически добавляется в `AnalyticsFacade.trackEvent`

`lib/core/analytics/analytics_facade.dart:36-65`:
- `user_id` (если есть)
- `traffic_source`, `campaign_id`, `campaign_name`, `audience_segment`, `is_organic`, `first_touch_at`, `last_touch_at`, `publisher`, `placement`, `creative_id` (из `AttributionSnapshot.toAnalyticsParams()`)
- Pre-existing `attribution_*` параметры

Это покрывает Acceptance 8.0 (campaign-level dashboards) из xlsx.

### 1.3 Существующие константы событий и места вызова

**Legacy AppsFlyer (`af_*`)** — должны остаться для backwards compatibility:
- `af_app_start` — `lib/core/services/apps_flyer_service.dart:76` (через `_appsflyerSdk.logEvent`)
- `af_sign_up` — `lib/features/auth/presentation/cubit/auth_cubit.dart:286`
- `af_login` — `lib/features/auth/presentation/cubit/auth_cubit.dart:156`
- `af_logout` — `lib/features/home/presentation/screens/profile_screen.dart:122`
- `af_account_deleted` — `lib/features/home/presentation/screens/profile_screen.dart:94`
- `af_phone_changed` — `lib/features/change_phone_number/presentation/cubit/change_phone_number_cubit.dart:161`
- `af_onboarding_complete` — `lib/features/onboarding/presentation/bloc/onboarding_bloc.dart:152`
- `af_purchase` — `lib/app/providers/user_provider.dart:175`, `:206`, `:246`, `:475`
- `af_coins_purchase` — `lib/features/payments/presentation/screens/payments_screen.dart:127` (legacy на стр. 130)
- `af_content_view` — `lib/app/providers/user_provider.dart:370,475`; `lib/features/home/presentation/cubit/home_cubit.dart:204,227`
- `af_screen_view` — auto через `AnalyticsRouteObserver`

**Современные (унифицированные) события без ast_-префикса** — в `AnalyticsEvents` объявлены ~50 шт (см. `analytics_events.dart:38-168`). Используются по всему приложению в фичах: `compatibility`, `natal_card`, `sonnik`, `anakra_chat`, `taro_cards`, `runes`, `love_deck`, `kelt_deck`, `horoscope`, `coins_paywall`, `subscription`, `shop`, `payments`, `home`, `onboarding`, `auth`, `change_phone_number`.

### 1.4 Конвенция имён

Текущая (до спеки 2.1):
- Константа: `lowerCamelCase` (`compatibilityPaywallView`)
- Событие: `snake_case` без префикса (`compatibility_paywall_view`)
- Параметр-константа: `lowerCamelCase` в `EventParams` (`paywallVariant`)
- Параметр-имя: `snake_case` (`paywall_variant`)

Новая (по спеке 2.1):
- Событие: **`ast_*` snake_case** (`ast_compatibility_paywall_view`)
- Каждое событие несёт **`canonical_event`** (`paywall_view` для примера выше)
- Имена параметров — те же snake_case (нужно добавить недостающие)

### 1.5 Что уже отправляется по дашбордам активации (P0)

| ast_* событие (спека) | Текущий эквивалент в коде | Файл:строка |
|---|---|---|
| `ast_app_open` | `af_app_start` (SDK) + `app_open`/`app_first_open` | `apps_flyer_service.dart:76`; `analytics_facade.dart:70-79` |
| `ast_onboarding_start` | `onboarding_start` | `onboarding_bloc.dart:40` |
| `ast_onboarding_complete` | `onboarding_complete` (legacy) + `onboarding_completed` | `onboarding_bloc.dart:152,154` |
| `ast_auth_phone_submit` | **отсутствует** (но `auth_code_requested` логируется) | `auth_cubit.dart:80` |
| `ast_auth_code_verify_success` | `auth_code_verified` | `auth_cubit.dart:116` |
| `ast_auth_code_verify_failed` | `auth_failed` (общий) | `auth_cubit.dart:87,120,128` |
| `ast_activation_complete` | `signup_completed` + `profile_completed` | `auth_cubit.dart:289-290` |
| `ast_birth_data_complete` | **отсутствует** | — |
| `ast_home_view` | **отсутствует** (только auto screen_view) | — |
| `ast_home_card_view` | **отсутствует** | — |
| `ast_home_card_click` | **отсутствует** | — |

---

## 2. Соответствие событий xlsx ↔ код

**Легенда статусов:**
- ✅ — реализовано и совместимо со спекой
- 🟡 — есть похожее событие в коде, нужно: a) добавить ast_* alias, b) добавить недостающие параметры (`canonical_event`, `origin_surface`, `offer_type`, и т.п.)
- ❌ — не реализовано
- ❓ — требует уточнения у пользователя/продакта

### 2.1 Activation / auth (8 событий)

| # | ast_* | canonical | Статус | Место в коде | Что не так |
|---|---|---|---|---|---|
| R2 | `ast_app_open` | `app_open` | 🟡 | `core/services/apps_flyer_service.dart:76` (af_app_start), `core/analytics/analytics_facade.dart:70` (`app_open`) | Нет `is_new_user`, нет ast_*-имени |
| R3 | `ast_onboarding_start` | `onboarding_start` | 🟡 | `features/onboarding/presentation/bloc/onboarding_bloc.dart:40` | Нет ast_*-имени, нет `canonical_event` |
| R4 | `ast_onboarding_complete` | `onboarding_complete` | 🟡 | `features/onboarding/presentation/bloc/onboarding_bloc.dart:152,154` | Нет ast_*-имени; нужно `steps_count`, `completion_seconds` |
| R5 | `ast_auth_phone_submit` | `auth_phone_submit` | ❌ | Нужно в `features/auth/presentation/cubit/auth_cubit.dart` рядом со `authCodeRequested` (стр. 80) — это **тот же момент** | — |
| R6 | `ast_auth_code_verify_success` | `auth_code_verify_success` | 🟡 | `features/auth/presentation/cubit/auth_cubit.dart:116` | Нет `is_signup`. Уточнить: код раздельно отправляет `authCodeVerified` (стр. 116) и `loginCompleted` (стр. 158) — нужен **`is_signup` boolean** для unification |
| R7 | `ast_auth_code_verify_failed` | `auth_code_verify_failed` | 🟡 | `features/auth/presentation/cubit/auth_cubit.dart:87,120,128` (общий `authFailed`) | Нужно отделить именно `code_verify_failed` от других auth-ошибок и добавить `failure_reason` |
| R8 | `ast_activation_complete` | `activation_complete` | 🟡 | `features/auth/presentation/cubit/auth_cubit.dart:289-290` (`signup_completed` + `profile_completed`) | Спека ясно говорит: «auth + обязательные profile/birth data завершены». Это **точка завершения `saveUser()`** — заменить или продублировать |
| R9 | `ast_birth_data_complete` | `profile_birth_data_complete` | ❌ | Триггер: момент, когда birth data заполнена в onboarding/signup. Нужно найти точку: после `updateBirthDate` в `AuthCubit` (стр. ~225-254) либо в onboarding-шагах ввода даты | — |

### 2.2 Home / discovery (3 события)

| # | ast_* | canonical | Статус | Место в коде |
|---|---|---|---|---|
| R10 | `ast_home_view` | `home_view` | ❌ | `features/home/presentation/screens/home_screen.dart` — `initState` или сразу после успешной загрузки `HomeCubit` |
| R11 | `ast_home_card_view` | `funnel_entry_view` | ❌ | Каждая карточка фуннеля на главной (compatibility, natal_chart, anakra, sonnik, tarot, runes, moon). Удобнее всего — в widget `initState`/`onVisibilityChange` каждой карточки в `features/home/presentation/widgets/` |
| R12 | `ast_home_card_click` | `funnel_entry_click` | ❌ | Колбэки `onTap` тех же карточек главной |

### 2.3 Compatibility (11 событий — R13..R23)

| # | ast_* | canonical | Статус | Место в коде |
|---|---|---|---|---|
| R13 | `ast_compatibility_start` | `funnel_start` | 🟡 | `features/compatibility/presentation/screens/create_compatibility_initial_screen.dart:40` (есть `compatibilityInputStarted` — рядом инициализация flow) |
| R14 | `ast_compatibility_input_complete` | `funnel_step_complete` | 🟡 | `create_compatibility_initial_screen.dart:87` (есть `compatibilityInputCompleted`) |
| R15 | `ast_compatibility_generation_complete` | `funnel_generation_complete` | 🟡 | `create_compatibility_initial_screen.dart:103,111` (есть `compatibilityCalculationCompleted`) |
| R16 | `ast_compatibility_result_view` | `funnel_result_view` | 🟡 | `create_compatibility_loaded_screen.dart:29` (есть `compatibilityResultView`) |
| R17 | `ast_compatibility_limit_reached` | `limit_reached` | ❌ | Триггер: когда пользователь упёрся в лимит попыток совместимости. Нужно найти точку в `CompatibilityCubit`/`UserProvider` где истекают `compatibilityRequests`. Сейчас отображается `compatibility_requests_left_screen` — момент перехода на него и есть событие |
| R18 | `ast_compatibility_paywall_view` | `paywall_view` | 🟡 | `create_compatibility_requests_left_screen.dart:31` + `create_compatibility_subscription_screen.dart:24` (есть `compatibilityPaywallView`) |
| R19 | `ast_compatibility_paywall_click` | `paywall_cta_click` | ❌ | Кнопки CTA на двух screens выше. Существующий `compatibilityUnlockClick` (`create_compatibility_requests_left_screen.dart:38`) — близкий по смыслу, но не привязан к `paywall_cta_click` canonical |
| R20 | `ast_compatibility_purchase_start` | `purchase_start` | 🟡 | `create_compatibility_subscription_screen.dart:78` (есть `purchaseStart`) — нет `origin_surface`, `offer_type`, `payment_type` |
| R21 | `ast_compatibility_purchase_success` | `purchase_success` | 🟡 | `create_compatibility_subscription_screen.dart:87` (есть `compatibilityPurchaseSuccess`) — **revenue event**, нужно `af_revenue` + `af_currency` |
| R22 | `ast_compatibility_purchase_failed` | `purchase_failed` | 🟡 | `create_compatibility_subscription_screen.dart:96` (есть `trackPurchaseFailed`) |
| R23 | `ast_compatibility_purchase_expired` | `purchase_expired` | ❌ | QR/payment session expired. Сейчас в `payments_screen.dart` есть `_PaymentScreenStatus.error` (стр. 116) и timeout (`_timeoutTimer`). Нужно различать «timeout» и сетевую ошибку |

### 2.4 Natal chart (11 событий — R24..R34)

| # | ast_* | canonical | Статус | Место в коде |
|---|---|---|---|---|
| R24 | `ast_natal_start` | `funnel_start` | 🟡 | `features/natal_card/natal_card_screen.dart:54` (есть `natalChartInputStarted` — играет роль start) |
| R25 | `ast_natal_birth_data_complete` | `funnel_step_complete` | ❌ | Триггер: birth data готовы для генерации (после ввода даты/времени/места). Сейчас событие сразу прыгает к `calculationStarted` (стр. 88) |
| R26 | `ast_natal_generation_complete` | `funnel_generation_complete` | 🟡 | `natal_card_screen.dart:91,103` (`natalChartCalculationCompleted`) |
| R27 | `ast_natal_result_view` | `funnel_result_view` | 🟡 | `natal_card_screen.dart:52` (`natalChartResultView`) |
| R28 | `ast_natal_section_view` | `content_engagement` | ❌ | Открытие конкретного раздела натальной карты (дома, аспекты, тип). Нужно найти все табы/секции в UI карты |
| R29 | `ast_natal_paywall_view` | `paywall_view` | 🟡 | Сейчас отсутствует — `natalChartPaywallView` объявлен в `analytics_events.dart:99`, но **не вызывается** ни в одном файле. Проверить |
| R30 | `ast_natal_paywall_click` | `paywall_cta_click` | 🟡 | `natal_card_screen.dart:87` (`natalChartUnlockClick`) — близко по смыслу |
| R31 | `ast_natal_purchase_start` | `purchase_start` | ❌ | Currently отсутствует. Где: внутри `subscription_screen.dart` или специфичного flow покупки natal_chart |
| R32 | `ast_natal_purchase_success` | `purchase_success` | 🟡 | `natalChartPurchaseSuccess` объявлен (`analytics_events.dart:101`), нужно проверить вызов |
| R33 | `ast_natal_purchase_failed` | `purchase_failed` | 🟡 | `natal_card_screen.dart:93` (`trackPurchaseFailed` для `FeatureName.natalChart`) |
| R34 | `ast_natal_purchase_expired` | `purchase_expired` | ❌ | См. R23 |

### 2.5 Sonnik (9 событий — R35..R43)

| # | ast_* | canonical | Статус | Место в коде |
|---|---|---|---|---|
| R35 | `ast_sonnik_start` | `funnel_start` | 🟡 | `features/sonnik/presentation/screens/create_sonnik_initial_screen.dart:36` (`sonnikFunnelStart`) |
| R36 | `ast_sonnik_dream_submit` | `funnel_step_complete` | 🟡 | `create_sonnik_initial_screen.dart:50` (`sonnikInputCompleted`) — нужно добавить `dream_length_band` |
| R37 | `ast_sonnik_generation_complete` | `funnel_generation_complete` | 🟡 | `create_sonnik_initial_screen.dart:62,70` (`calculationCompleted`) |
| R38 | `ast_sonnik_result_view` | `funnel_result_view` | 🟡 | `create_sonnik_loaded_screen.dart:26` (`sonnikResultView`) |
| R39 | `ast_sonnik_limit_reached` | `limit_reached` | ❌ | Триггер: переход на `create_sonnik_requests_left_screen` |
| R40 | `ast_sonnik_paywall_view` | `paywall_view` | 🟡 | `create_sonnik_requests_left_screen.dart:26`, `create_sonnik_subscription_screen.dart:24` (`sonnikPaywallView`) |
| R41 | `ast_sonnik_paywall_click` | `paywall_cta_click` | 🟡 | `create_sonnik_requests_left_screen.dart:36` (`sonnikUnlockClick`) |
| R42 | `ast_sonnik_purchase_success` | `purchase_success` | 🟡 | `create_sonnik_subscription_screen.dart:85` (`sonnikPurchaseSuccess`) — **revenue event** |
| R43 | `ast_sonnik_purchase_failed` | `purchase_failed` | 🟡 | `create_sonnik_subscription_screen.dart:94` (`trackPurchaseFailed`) |

### 2.6 Anakra (9 событий — R44..R52)

| # | ast_* | canonical | Статус | Место в коде |
|---|---|---|---|---|
| R44 | `ast_anakra_start` | `funnel_start` | 🟡 | `features/anakra_chat/presentation/screens/anakra_chat_screen.dart:35` (`anakraChatOpen`) |
| R45 | `ast_anakra_message_sent` | `funnel_step_complete` | 🟡 | `anakra_chat_screen.dart:78` (`anakraQuestionSent`) — нужно добавить `message_length_band`, `message_index` |
| R46 | `ast_anakra_response_view` | `funnel_result_view` | 🟡 | `anakra_chat_screen.dart:86` (`anakraAnswerReceived`) |
| R47 | `ast_anakra_quick_action_click` | `content_engagement` | ❌ | Quick actions в чате (`anakra_chat_screen.dart` — кнопки быстрых тем). Нужно найти конкретный widget |
| R48 | `ast_anakra_limit_reached` | `limit_reached` | 🟡 | `anakra_chat_screen.dart:70,96` (`anakraLimitReached`) |
| R49 | `ast_anakra_paywall_view` | `paywall_view` | 🟡 | `create_anakra_requests_left_screen.dart:26`, `create_anakra_subscription_screen.dart:24` (`anakraPaywallView`) |
| R50 | `ast_anakra_paywall_click` | `paywall_cta_click` | 🟡 | `create_anakra_requests_left_screen.dart:36` (`anakraUnlockClick`) |
| R51 | `ast_anakra_purchase_success` | `purchase_success` | 🟡 | `create_anakra_subscription_screen.dart:88` (`anakraPurchaseSuccess`) — **revenue event** |
| R52 | `ast_anakra_purchase_failed` | `purchase_failed` | 🟡 | `create_anakra_subscription_screen.dart:97` (`trackPurchaseFailed`) |

### 2.7 Tarot / runes / moon / affirmations (20 событий — R53..R72)

| # | ast_* | canonical | Статус | Место в коде |
|---|---|---|---|---|
| R53 | `ast_tarot_start` | `funnel_start` | 🟡 | `features/taro_cards/taro_cards_screen.dart:107` (`tarotDeckOpen`) |
| R54 | `ast_tarot_card_reveal` | `funnel_step_complete` | 🟡 | `home_cubit.dart:204` + `user_provider.dart:370` (`tarotCardView`) — также `content_provider.dart:317,478,483` (`tarotCardView`, `tarotSpreadStarted`) |
| R55 | `ast_tarot_locked_view` | `locked_content_view` | 🟡 | `taro_cards_screen.dart:253` (`lockedContentView`) |
| R56 | `ast_tarot_paywall_view` | `paywall_view` | 🟡 | `taro_cards_screen.dart:141,196,257` (`paywallView` for tarot) |
| R57 | `ast_tarot_purchase_success` | `purchase_success` | 🟡 | `taro_cards_screen.dart:159,214` (`trackPurchaseSuccess` для loveDeck/keltDeck) — но **сейчас они в монетах**, а спека ожидает revenue. См. §11 Q3 |
| R58 | `ast_runes_start` | `funnel_start` | 🟡 | `features/runes/runes_screen.dart:104` (`runeView`) — играет роль |
| R59 | `ast_runes_reveal` | `funnel_step_complete` | 🟡 | `home_cubit.dart:227` (`contentView` rune_of_day) + `runes_screen.dart` |
| R60 | `ast_runes_locked_view` | `locked_content_view` | 🟡 | `runes_screen.dart:138` (`lockedContentView`) |
| R61 | `ast_runes_paywall_view` | `paywall_view` | 🟡 | `runes_screen.dart` (по аналогии с tarot) |
| R62 | `ast_runes_purchase_success` | `purchase_success` | ❌ | Currently реально не отправляется отдельно для runes |
| R63 | `ast_moon_start` | `funnel_start` | 🟡 | `features/home/presentation/screens/moon_screen.dart:33` |
| R64 | `ast_moon_tab_view` | `content_engagement` | ❌ | Переключение day/week/month/year табов на `moon_screen.dart`/`horoscope_screen.dart`. Нужно добавить callback на `onTabChanged` |
| R65 | `ast_moon_generation_complete` | `funnel_generation_complete` | 🟡 | `horoscope_screen.dart:83` (`calculationCompleted`) |
| R66 | `ast_moon_paywall_view` | `paywall_view` | 🟡 | `horoscope_screen.dart:109` (`paywallView`) |
| R67 | `ast_moon_purchase_success` | `purchase_success` | 🟡 | `horoscope_screen.dart:86` (`trackPurchaseSuccess` for FeatureName.horoscope) |
| R68 | `ast_affirmations_start` | `funnel_start` | ❌ | **Отсутствует целиком модуль аналитики `affirmation`** — `features/affirmation/` не содержит ни одного `trackEvent` |
| R69 | `ast_affirmation_card_view` | `funnel_result_view` | ❌ | Аналогично |
| R70 | `ast_affirmation_engagement` | `content_engagement` | ❌ | save/share/audio/favorite/swipe в `affirmation_card_widget.dart` |
| R71 | `ast_affirmation_locked_view` | `locked_content_view` | ❌ | Аналогично |
| R72 | `ast_affirmation_paywall_view` | `paywall_view` | ❌ | Аналогично |

### 2.8 Coins / payments / subscription (19 событий — R73..R91)

| # | ast_* | canonical | Статус | Место в коде |
|---|---|---|---|---|
| R73 | `ast_coin_spend_start` | `internal_coin_spend_start` | ❌ | Любой кейс попытки `UserProvider.spendBalance(...)` или аналог. Глобально — в `user_provider.dart` есть `addBalance(...)` и `payment_screen` — но точки **списания** разбросаны по фичам |
| R74 | `ast_coin_spend_success` | `internal_coin_spend_success` | ❌ | После успешного списания |
| R75 | `ast_coin_spend_failed` | `internal_coin_spend_failed` | ❌ | Insufficient balance / ошибка |
| R76 | `ast_coin_paywall_view` | `paywall_view` | 🟡 | `features/coins_paywall/presentation/screens/coins_paywall_screen.dart:26` (`coinsPaywallView`) |
| R77 | `ast_coin_package_select` | `funnel_step_complete` | 🟡 | `coins_paywall_screen.dart:47` (`coinsPackageSelected`) |
| R78 | `ast_coin_purchase_start` | `purchase_start` | 🟡 | `coins_paywall_screen.dart:56` (`coinsPurchaseStart`) |
| R79 | `ast_coin_purchase_success` | `purchase_success` | 🟡 | `payments_screen.dart:127` (`af_coins_purchase` legacy) + `:139` (`coinsPurchaseSuccess`) — **revenue event** |
| R80 | `ast_coin_purchase_failed` | `purchase_failed` | ❌ | `payments_screen.dart:114-117` (error path) — нужно добавить событие |
| R81 | `ast_coin_purchase_cancelled` | `purchase_cancelled` | ❌ | Когда пользователь отменяет/уходит со страницы оплаты до завершения |
| R82 | `ast_coin_purchase_expired` | `purchase_expired` | ❌ | `payments_screen.dart:_timeoutTimer` истёк |
| R83 | `ast_payment_method_select` | `payment_method_select` | ❌ | Выбор способа оплаты (если есть UI выбора). У ArcoPay есть несколько methods — где это в UI? См. §11 Q5 |
| R84 | `ast_subscription_paywall_view` | `paywall_view` | 🟡 | `subscription_screen.dart:35` (`subscriptionPaywallView`) |
| R85 | `ast_subscription_plan_select` | `funnel_step_complete` | 🟡 | `subscription_screen.dart:66` (`subscriptionPlanSelected`) |
| R86 | `ast_subscription_purchase_start` | `purchase_start` | 🟡 | `subscription_screen.dart:294` (`subscriptionPurchaseStart`) |
| R87 | `ast_subscription_purchase_success` | `purchase_success` | 🟡 | `subscription_screen.dart:333` (`subscriptionPurchaseSuccess`) — **revenue event** |
| R88 | `ast_subscription_purchase_failed` | `purchase_failed` | ❌ | Нужно добавить рядом с :333 |
| R89 | `ast_purchase_restore_click` | `purchase_restore_click` | ❌ | См. §11 Q6 — есть ли restore UI |
| R90 | `ast_purchase_restore_success` | `purchase_restore_success` | ❌ | Аналогично |
| R91 | `ast_purchase_restore_failed` | `purchase_restore_failed` | ❌ | Аналогично |

### 2.9 Profile / shop / account actions (7 событий — R92..R98)

| # | ast_* | canonical | Статус | Место в коде |
|---|---|---|---|---|
| R92 | `ast_profile_view` | `profile_view` | ❌ | `features/home/presentation/screens/profile_screen.dart` — `initState` |
| R93 | `ast_profile_menu_click` | `profile_menu_click` | ❌ | Каждый пункт меню профиля. Нужно добавить `menu_item` параметр на onTap каждой строки |
| R94 | `ast_shop_view` | `shop_view` | 🟡 | `features/shop/presentation/shop_screen.dart:31` (`funnelStart` for shop) — можно переименовать в `shopView` или добавить отдельное событие |
| R95 | `ast_shop_item_select` | `shop_item_select` | 🟡 | `user_provider.dart:175` (`af_purchase` for shop item) — нужен явный event `ast_shop_item_select` ДО покупки |
| R96 | `ast_account_logout` | `account_logout` | 🟡 | `profile_screen.dart:122` (`af_logout`) — alias добавить опционально |
| R97 | `ast_account_delete` | `account_delete` | 🟡 | `profile_screen.dart:94` (`af_account_deleted`) — alias добавить опционально |
| R98 | `ast_phone_change_success` | `phone_change_success` | 🟡 | `change_phone_number_cubit.dart:161` (`af_phone_changed`) — alias добавить опционально |

### 2.10 P1 Raw Detail Events (5 событий)

| ast_* | canonical | Статус | Комментарий |
|---|---|---|---|
| `ast_screen_view` | `screen_view` | 🟡 | Сейчас `AnalyticsRouteObserver` шлёт `af_screen_view`. Можно добавить ast_*-alias на уровне observer |
| `ast_funnel_step_view` | `funnel_step_view` | ❌ | Generic event для важных steps без explicit P0 события. Низкий приоритет |
| `ast_content_engagement` | `content_engagement` | ❌ | Generic content action |
| `ast_error_state_view` | `error_state_view` | ❌ | Любые экраны ошибок. Найти в коде все error states (например, `payments_screen.dart:_PaymentScreenStatus.error`) |
| `ast_notification_permission_result` | `permission_result` | ❌ | Push-permission prompt. См. §11 Q7 — реализован ли push? |

---

## 3. Целевая архитектура

### 3.1 Высокоуровневая диаграмма

```
┌─────────────────────────────────────────────────────────────────┐
│  UI layer (screens, cubits, blocs, widgets)                      │
└──────────────────────────────┬──────────────────────────────────┘
                               │ типизированные методы
                               │ trackCompatibilityStart(entrySurface: ...)
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  ProductAnalyticsService (НОВЫЙ слой) — lib/core/analytics/      │
│  ─ методы на каждое ast_* событие                                │
│  ─ типобезопасные параметры (enum-ы для entry_surface,          │
│    offer_type, payment_type, и т.п.)                             │
│  ─ автоматически проставляет canonical_event + funnel_type       │
└──────────────────────────────┬──────────────────────────────────┘
                               │ trackEvent(name, params)
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  AnalyticsFacade (СУЩЕСТВУЮЩИЙ) — без изменений                  │
│  ─ авто-merge user_id + attribution                              │
│  ─ debug log                                                     │
└──────────────────────────────┬──────────────────────────────────┘
                               ▼
                       AppsFlyerService.logEvent(...)
```

### 3.2 Mapping rule (Acceptance 5.0, 6.0)

Адаптер (`ProductAnalyticsService`) при отправке любого `ast_*` события автоматически добавляет:
- **`canonical_event`** — берётся из таблицы маппинга (статичная карта в коде).
- **`funnel_type`** — выводится из имени события (например, `ast_compatibility_*` → `funnel_type=compatibility`). UI **не передаёт `funnel_type` вручную**, кроме generic-событий вроде `ast_home_card_view`.

### 3.3 Контрактные принципы (из xlsx Acceptance + Do Not Send)

1. **Revenue rule (4.0):** только `*_purchase_success` несёт `af_revenue` + `af_currency`. На каждую транзакцию — **ровно один** такой event.
2. **Internal coin spend ≠ revenue.** События `ast_coin_spend_*` не содержат `af_revenue`.
3. **PII never sent (9.0):** телефон, имя, точная дата/место, текст сна/сообщений, partner names, payment payload → заменяются на boolean/band. Список — лист `Do Not Send`.
4. **Payload size (10.0):** держать суммарную длину params < 1000 chars.
5. **Backwards compat:** все `af_*` события остаются — дашборды на них завязаны.

---

## 4. Список новых констант (для разработчика)

### 4.1 Новые имена событий — добавить в `lib/core/analytics/analytics_events.dart`

Опция А (рекомендуется): создать **новый отдельный файл** `lib/core/analytics/ast_events.dart` — `abstract final class AstEvents` — чтобы не смешивать с legacy/transitional константами.

Полный список (97 P0 + 5 P1) — все из колонки `appsflyer_event_name` xlsx:

```dart
abstract final class AstEvents {
  AstEvents._();

  // Activation / auth
  static const String appOpen = 'ast_app_open';
  static const String onboardingStart = 'ast_onboarding_start';
  static const String onboardingComplete = 'ast_onboarding_complete';
  static const String authPhoneSubmit = 'ast_auth_phone_submit';
  static const String authCodeVerifySuccess = 'ast_auth_code_verify_success';
  static const String authCodeVerifyFailed = 'ast_auth_code_verify_failed';
  static const String activationComplete = 'ast_activation_complete';
  static const String birthDataComplete = 'ast_birth_data_complete';

  // Home / discovery
  static const String homeView = 'ast_home_view';
  static const String homeCardView = 'ast_home_card_view';
  static const String homeCardClick = 'ast_home_card_click';

  // Compatibility (R13..R23)
  static const String compatibilityStart = 'ast_compatibility_start';
  static const String compatibilityInputComplete = 'ast_compatibility_input_complete';
  static const String compatibilityGenerationComplete = 'ast_compatibility_generation_complete';
  static const String compatibilityResultView = 'ast_compatibility_result_view';
  static const String compatibilityLimitReached = 'ast_compatibility_limit_reached';
  static const String compatibilityPaywallView = 'ast_compatibility_paywall_view';
  static const String compatibilityPaywallClick = 'ast_compatibility_paywall_click';
  static const String compatibilityPurchaseStart = 'ast_compatibility_purchase_start';
  static const String compatibilityPurchaseSuccess = 'ast_compatibility_purchase_success';
  static const String compatibilityPurchaseFailed = 'ast_compatibility_purchase_failed';
  static const String compatibilityPurchaseExpired = 'ast_compatibility_purchase_expired';

  // Natal chart (R24..R34) — аналогично, по таблице xlsx
  static const String natalStart = 'ast_natal_start';
  static const String natalBirthDataComplete = 'ast_natal_birth_data_complete';
  static const String natalGenerationComplete = 'ast_natal_generation_complete';
  static const String natalResultView = 'ast_natal_result_view';
  static const String natalSectionView = 'ast_natal_section_view';
  static const String natalPaywallView = 'ast_natal_paywall_view';
  static const String natalPaywallClick = 'ast_natal_paywall_click';
  static const String natalPurchaseStart = 'ast_natal_purchase_start';
  static const String natalPurchaseSuccess = 'ast_natal_purchase_success';
  static const String natalPurchaseFailed = 'ast_natal_purchase_failed';
  static const String natalPurchaseExpired = 'ast_natal_purchase_expired';

  // Sonnik (R35..R43)
  static const String sonnikStart = 'ast_sonnik_start';
  static const String sonnikDreamSubmit = 'ast_sonnik_dream_submit';
  static const String sonnikGenerationComplete = 'ast_sonnik_generation_complete';
  static const String sonnikResultView = 'ast_sonnik_result_view';
  static const String sonnikLimitReached = 'ast_sonnik_limit_reached';
  static const String sonnikPaywallView = 'ast_sonnik_paywall_view';
  static const String sonnikPaywallClick = 'ast_sonnik_paywall_click';
  static const String sonnikPurchaseSuccess = 'ast_sonnik_purchase_success';
  static const String sonnikPurchaseFailed = 'ast_sonnik_purchase_failed';

  // Anakra (R44..R52)
  static const String anakraStart = 'ast_anakra_start';
  static const String anakraMessageSent = 'ast_anakra_message_sent';
  static const String anakraResponseView = 'ast_anakra_response_view';
  static const String anakraQuickActionClick = 'ast_anakra_quick_action_click';
  static const String anakraLimitReached = 'ast_anakra_limit_reached';
  static const String anakraPaywallView = 'ast_anakra_paywall_view';
  static const String anakraPaywallClick = 'ast_anakra_paywall_click';
  static const String anakraPurchaseSuccess = 'ast_anakra_purchase_success';
  static const String anakraPurchaseFailed = 'ast_anakra_purchase_failed';

  // Tarot / runes / moon / affirmations (R53..R72)
  static const String tarotStart = 'ast_tarot_start';
  static const String tarotCardReveal = 'ast_tarot_card_reveal';
  static const String tarotLockedView = 'ast_tarot_locked_view';
  static const String tarotPaywallView = 'ast_tarot_paywall_view';
  static const String tarotPurchaseSuccess = 'ast_tarot_purchase_success';
  static const String runesStart = 'ast_runes_start';
  static const String runesReveal = 'ast_runes_reveal';
  static const String runesLockedView = 'ast_runes_locked_view';
  static const String runesPaywallView = 'ast_runes_paywall_view';
  static const String runesPurchaseSuccess = 'ast_runes_purchase_success';
  static const String moonStart = 'ast_moon_start';
  static const String moonTabView = 'ast_moon_tab_view';
  static const String moonGenerationComplete = 'ast_moon_generation_complete';
  static const String moonPaywallView = 'ast_moon_paywall_view';
  static const String moonPurchaseSuccess = 'ast_moon_purchase_success';
  static const String affirmationsStart = 'ast_affirmations_start';
  static const String affirmationCardView = 'ast_affirmation_card_view';
  static const String affirmationEngagement = 'ast_affirmation_engagement';
  static const String affirmationLockedView = 'ast_affirmation_locked_view';
  static const String affirmationPaywallView = 'ast_affirmation_paywall_view';

  // Coins / payments / subscription (R73..R91)
  static const String coinSpendStart = 'ast_coin_spend_start';
  static const String coinSpendSuccess = 'ast_coin_spend_success';
  static const String coinSpendFailed = 'ast_coin_spend_failed';
  static const String coinPaywallView = 'ast_coin_paywall_view';
  static const String coinPackageSelect = 'ast_coin_package_select';
  static const String coinPurchaseStart = 'ast_coin_purchase_start';
  static const String coinPurchaseSuccess = 'ast_coin_purchase_success';
  static const String coinPurchaseFailed = 'ast_coin_purchase_failed';
  static const String coinPurchaseCancelled = 'ast_coin_purchase_cancelled';
  static const String coinPurchaseExpired = 'ast_coin_purchase_expired';
  static const String paymentMethodSelect = 'ast_payment_method_select';
  static const String subscriptionPaywallView = 'ast_subscription_paywall_view';
  static const String subscriptionPlanSelect = 'ast_subscription_plan_select';
  static const String subscriptionPurchaseStart = 'ast_subscription_purchase_start';
  static const String subscriptionPurchaseSuccess = 'ast_subscription_purchase_success';
  static const String subscriptionPurchaseFailed = 'ast_subscription_purchase_failed';
  static const String purchaseRestoreClick = 'ast_purchase_restore_click';
  static const String purchaseRestoreSuccess = 'ast_purchase_restore_success';
  static const String purchaseRestoreFailed = 'ast_purchase_restore_failed';

  // Profile / shop / account (R92..R98)
  static const String profileView = 'ast_profile_view';
  static const String profileMenuClick = 'ast_profile_menu_click';
  static const String shopView = 'ast_shop_view';
  static const String shopItemSelect = 'ast_shop_item_select';
  static const String accountLogout = 'ast_account_logout';
  static const String accountDelete = 'ast_account_delete';
  static const String phoneChangeSuccess = 'ast_phone_change_success';

  // P1 raw detail
  static const String screenView = 'ast_screen_view';
  static const String funnelStepView = 'ast_funnel_step_view';
  static const String contentEngagement = 'ast_content_engagement';
  static const String errorStateView = 'ast_error_state_view';
  static const String notificationPermissionResult = 'ast_notification_permission_result';
}
```

### 4.2 Новые параметры — расширить `lib/core/analytics/event_params.dart`

```dart
abstract final class EventParams {
  // ... существующие

  // Canonical / taxonomy
  static const String canonicalEvent = 'canonical_event';

  // Surface / navigation context
  static const String originSurface = 'origin_surface';        // Существует entrySurface — добавить originSurface
  static const String entryPointId = 'entry_point_id';
  static const String position = 'position';
  static const String ctaName = 'cta_name';
  static const String screenName = 'screen_name';
  static const String menuItem = 'menu_item';

  // User lifecycle
  static const String isNewUser = 'is_new_user';
  static const String isSignup = 'is_signup';
  static const String stepsCount = 'steps_count';
  static const String completionSeconds = 'completion_seconds';

  // Birth / profile (privacy-safe только)
  static const String hasBirthTime = 'has_birth_time';
  static const String birthTimePrecision = 'birth_time_precision';
  static const String hasBirthPlace = 'has_birth_place';
  static const String genderSelected = 'gender_selected';
  static const String inputMode = 'input_mode';

  // Compatibility / sonnik / anakra
  static const String partnerDataCompleteness = 'partner_data_completeness';
  static const String dreamLengthBand = 'dream_length_band';
  static const String messageLengthBand = 'message_length_band';
  static const String messageIndex = 'message_index';

  // Generation / errors
  static const String generationStatus = 'generation_status';
  static const String generationSeconds = 'generation_seconds';
  static const String errorType = 'error_type';

  // Limits / entitlements
  static const String limitType = 'limit_type';
  static const String requestsLeft = 'requests_left';
  static const String limitPeriod = 'limit_period';

  // Payment / monetization (расширение)
  static const String paymentType = 'payment_type';            // existing purchaseType — будем сосуществовать
  static const String paymentProvider = 'payment_provider';
  static const String paymentMethodType = 'payment_method_type';
  static const String coinAmount = 'coin_amount';
  static const String balanceBefore = 'balance_before';
  static const String balanceAfter = 'balance_after';
  static const String planId = 'plan_id';
  static const String timeToExpire = 'time_to_expire';
  static const String productType = 'product_type';

  // Revenue (AppsFlyer reserved)
  static const String afRevenue = 'af_revenue';
  static const String afCurrency = 'af_currency';

  // Funnel taxonomy
  static const String funnelType = 'funnel_type';              // существующий уже есть

  // Shop / generic
  static const String itemId = 'item_id';
  static const String itemType = 'item_type';

  // P1
  static const String contentType = 'content_type';
  static const String contentId = 'content_id';
  static const String actionType = 'action_type';
  static const String permissionType = 'permission_type';
  static const String permissionStatus = 'permission_status';
}
```

### 4.3 Новые enum-ы — добавить в `lib/core/analytics/` (отдельные файлы)

```dart
// entry_surface_enum.dart
enum EntrySurface {
  home, landing, profile, push, deepLink, appStore, shop, anakra, unknown;
  String get eventValue { /* snake_case mapping */ }
}

// offer_type_enum.dart
enum OfferType {
  subscription, requestPack, coinPackage, oneOffUnlock, shopItem, proUnlock;
  // eventValue: subscription, request_pack, coin_package, one_off_unlock, shop_item, pro_unlock
}

// payment_type_enum.dart
enum PaymentType { realMoney, subscription, internalCoins; /* real_money, subscription, internal_coins */ }

// birth_time_precision_enum.dart
enum BirthTimePrecision { exact, approxDay, approxNight, unknown; }
```

Funnel-type enum можно расширить существующий `FeatureName`, либо добавить отдельный `FunnelType` — рекомендую отдельный, потому что в xlsx funnel_type включает значения вроде `shop`, `profile`, которые в `FeatureName` отсутствуют.

### 4.4 Canonical-event mapping table

Внутри `ProductAnalyticsService` — статичная карта `Map<String, String>` ast_event_name → canonical_event (97 пар, прямо из колонки `canonical_event` xlsx).

---

## 5. План имплементации (задачи для Senior Developer)

Атомарные таски, упорядоченные по зависимостям. Каждая — отдельный PR.

### 5.1 Фундамент (без видимых изменений в продакшене)

| ID | Файлы | Действие | Зависимости | Риск |
|---|---|---|---|---|
| T1 | `lib/core/analytics/ast_events.dart` (NEW) | Создать `AstEvents` со всеми 102 константами по §4.1 | — | низкий |
| T2 | `lib/core/analytics/event_params.dart` | Добавить все новые ключи из §4.2. Существующие не трогать | — | низкий |
| T3 | `lib/core/analytics/entry_surface.dart`, `offer_type.dart`, `payment_type.dart`, `birth_time_precision.dart`, `limit_type.dart`, `funnel_type.dart` (NEW) | Создать enum-ы с `eventValue` геттером по §4.3 + xlsx `Dictionaries` | — | низкий |
| T4 | `lib/core/analytics/product_analytics_service.dart` (NEW) | Создать `ProductAnalyticsService` со скелетом: `_facade`, `_canonicalEventMap` (97 строк), приватный `_track(astEvent, params)` который добавляет `canonical_event` + `funnel_type` | T1, T2, T3 | низкий |
| T5 | `lib/core/di/di.dart` | Зарегистрировать `ProductAnalyticsService` как lazy singleton | T4 | низкий |

### 5.2 По фичам — добавить вызовы (P0 события)

Каждая задача:
1. В `ProductAnalyticsService` добавляет типобезопасный метод (например, `trackCompatibilityStart(EntrySurface entrySurface)`).
2. В целевом файле вызывает этот метод **рядом** (не заменяя!) с существующим `facade.trackEvent(...)`. Legacy остаётся.

Для каждой фичи указано: целевой файл и точка вызова.

#### T6: Auth / activation (R5..R9)
- Файл: `lib/features/auth/presentation/cubit/auth_cubit.dart`
- `ast_auth_phone_submit` — после успешного `authCodeRequested` (стр. 80)
- `ast_auth_code_verify_success(isSignup: bool)` — стр. 116 (нужно вычислить `isSignup` из контекста: если `_currentUser?.id == null` до verify)
- `ast_auth_code_verify_failed(failureReason)` — стр. 87, 120, 128 — **только в части кода, относящейся именно к verify**, не в общем `authFailed`
- `ast_activation_complete` — `saveUser()` стр. 291 (после `emit(UserSaved)`)
- `ast_birth_data_complete` — добавить вызов в `_emitUserUpdated` или явно после `updateBirthDate` (стр. 254), при условии что birthDate и birthTime валидны

#### T7: Onboarding (R3, R4)
- Файл: `lib/features/onboarding/presentation/bloc/onboarding_bloc.dart`
- `ast_onboarding_start` — стр. 40, рядом с `onboardingStart`
- `ast_onboarding_complete(stepsCount, completionSeconds)` — стр. 152, рядом с `onboardingComplete`. Нужен **timer** — стартовать в конструкторе блока или на `onboardingStart`

#### T8: Home (R10..R12)
- Файлы:
  - `lib/features/home/presentation/screens/home_screen.dart` — `ast_home_view` в `initState`
  - Карточки фуннелей: см. `lib/features/home/presentation/widgets/` — найти список widget-карточек. Каждая карточка → `ast_home_card_view` на показе (можно через `VisibilityDetector` или просто в `build` с дебаунсом) + `ast_home_card_click` в `onTap`
- Необходимо ввести **стабильные `entry_point_id`** для каждой карточки

#### T9: Compatibility (R13..R23)
- Файлы:
  - `lib/features/compatibility/presentation/screens/create_compatibility_initial_screen.dart`
  - `.../create_compatibility_loaded_screen.dart`
  - `.../create_compatibility_requests_left_screen.dart`
  - `.../create_compatibility_subscription_screen.dart`
- Соответствие точек вставки указано в §2.3

#### T10: Natal chart (R24..R34)
- Файл: `lib/features/natal_card/natal_card_screen.dart` + точки покупки (см. §11 Q4)
- Все события из §2.4

#### T11: Sonnik (R35..R43)
- Файлы: `lib/features/sonnik/presentation/screens/*`
- Особое внимание: добавить вычисление `dream_length_band` (short/medium/long) **до** отправки текста в API, текст НЕ логировать

#### T12: Anakra (R44..R52)
- Файлы: `lib/features/anakra_chat/presentation/screens/*`
- Особое внимание: `message_length_band`, `message_index` (счётчик сессии чата) — без текста сообщения

#### T13: Tarot / runes / moon (R53..R67)
- Файлы:
  - `lib/features/taro_cards/taro_cards_screen.dart`
  - `lib/features/runes/runes_screen.dart`
  - `lib/features/home/presentation/screens/moon_screen.dart`
  - `lib/features/horoscope/presentation/horoscope_screen.dart`
  - `lib/app/providers/content_provider.dart` (точки `tarotCardView`, `tarotSpreadStarted`)
  - `lib/features/home/presentation/cubit/home_cubit.dart` (стр. 204, 227 — `tarot_card_of_day`, `rune_of_day`)

#### T14: Affirmations (R68..R72) — **полностью новая интеграция**
- Файлы: `lib/features/affirmation/widgets/affirmation_card_widget.dart`, `affirmation_category_widget.dart`, `lib/features/home/presentation/widgets/affirmation_of_the_day_widget.dart`, маршрут `lib/core/routing/routes/affirmation_route.dart`
- Все 5 событий с нуля

#### T15: Coin spend / coin purchase (R73..R83)
- Файлы:
  - `lib/features/coins_paywall/presentation/screens/coins_paywall_screen.dart`
  - `lib/features/payments/presentation/screens/payments_screen.dart` (success/failed/expired/cancelled)
  - `lib/app/providers/user_provider.dart` (точка списания coins для compatibility/anakra/sonnik/horoscope — нужно найти все вызовы `spendBalance`-подобных методов)
- Все события `ast_coin_spend_*` нужны для понимания «куда уходят звёзды» — это самостоятельная funnel

#### T16: Subscription (R84..R88)
- Файл: `lib/features/subscription/presentation/subscription_screen.dart`
- Все события из §2.8 субсекции

#### T17: Restore purchases (R89..R91)
- Зависит от §11 Q6

#### T18: Profile / shop / account (R92..R98)
- Файлы:
  - `lib/features/home/presentation/screens/profile_screen.dart` — `ast_profile_view` (initState), `ast_profile_menu_click(menuItem)` на каждый пункт меню, **alias** `ast_account_logout` (стр. 122) и `ast_account_delete` (стр. 94)
  - `lib/features/shop/presentation/shop_screen.dart` — `ast_shop_view` (initState), `ast_shop_item_select(itemId)` на onTap каждого item
  - `lib/features/change_phone_number/presentation/cubit/change_phone_number_cubit.dart:161` — alias `ast_phone_change_success`

#### T19: P1 events (`ast_screen_view`, `ast_error_state_view`)
- `lib/core/analytics/analytics_route_observer.dart` — добавить отправку `ast_screen_view` в дополнение к `af_screen_view`
- `ast_error_state_view` — найти все error-states (`payments_screen.dart`, generation errors в `compatibility`/`sonnik`/`natal_chart`), добавить вызов
- `ast_notification_permission_result` — после iOS/Android push permission prompt (см. §11 Q7)

### 5.3 Чистовая полировка

| ID | Файлы | Действие |
|---|---|---|
| T20 | Все ранее изменённые файлы | Прогнать линтер, убедиться что `kDebugMode` отладочный print показывает корректные ast_*-события |
| T21 | `lib/app/providers/user_provider.dart` | **Аудит revenue:** найти все места отправки `af_revenue`/`AnalyticsEvents.paramRevenue`. Гарантировать: только один `ast_*_purchase_success` per транзакция несёт revenue. Текущее состояние — есть риск двойного учёта (см. §6 Risk #2) |
| T22 | `lib/features/payments/presentation/screens/payments_screen.dart` | Развести success/failed/cancelled/expired по разным событиям + `payment_provider: 'arcopay'` или `'yookassa'` (уточнить — §11 Q2) |

---

## 6. Риски и неоднозначности (НЕ блокирующие, но требуют внимания)

1. **Двойной revenue.** В `user_provider.dart` отправляется `af_purchase` с `paramRevenue: type.price` (в монетах) — это **не real-money**, но AppsFlyer может посчитать как доход. Нужен аудит при имплементации T21. Спека прямо запрещает revenue для internal coin spend.
2. **`af_coins_purchase` дублируется с `coinsPurchaseSuccess`.** В `payments_screen.dart:130-148` отправляются ОБА — legacy и новый. После добавления `ast_coin_purchase_success` с `af_revenue` получится **три события**. Legacy `af_coins_purchase` остаётся для backwards compat, но revenue должен быть **только в одном из трёх** — желательно в новом `ast_coin_purchase_success`. Спека также упоминает, что legacy `af_*` SDK-события могут сами по себе участвовать в revenue-агрегации AppsFlyer.
3. **`af_content_view` событие на одну и ту же карту дня может отправиться дважды** — `home_cubit.dart:204` (tarot_card_of_day) и `user_provider.dart:370` (cardId через content_provider). Это **не новая проблема**, но при добавлении `ast_tarot_card_reveal` нужно решить, на каком уровне его отправлять, чтобы не дублировать.
4. **Auth event split.** Сейчас `authFailed` отправляется для трёх разных ситуаций (request OTP fail, verify code fail, save user fail). Спека требует именно `code_verify_failed` — нужно разделить.
5. **Limit reached vs paywall view.** Часто оба события происходят на одном экране (e.g. `compatibility_requests_left_screen`). Спека различает их: `limit_reached` — факт исчерпания, `paywall_view` — показ offer. Если они логически = один момент, нужно отправлять **оба** последовательно.

---

## 7. Изменения API/контрактов

### 7.1 Firestore
**Без изменений.**

### 7.2 Firebase Functions
**Без изменений** — события идут напрямую в AppsFlyer SDK.

### 7.3 GoRouter
**Опционально:** Добавить в каждый `*Route` стабильный `screen_name` id для `ast_screen_view`. Сейчас `AnalyticsRouteObserver` использует имя из `GoRouter` — нужно проверить, что они stable.

### 7.4 AppsFlyer dashboard
- Создать новые dashboard-секции под `ast_*` события (см. xlsx `Dashboards` лист) — это задача BI, не разработки. **Coordinate с Alex**.

---

## 8. Стратегия тестирования

### 8.1 Unit
- `ProductAnalyticsService` — тестировать через mock `AnalyticsFacade`:
  - Каждый метод отправляет правильное `ast_*` имя
  - `canonical_event` всегда присутствует и корректен
  - `funnel_type` автоматически вывелся
  - PII-параметры не утекают (negative tests)
- Enum `*Eventvalue` getters — табличные тесты

### 8.2 Widget / интеграционные
Для каждого funnel — happy-path widget test:
1. Запустить flow до `purchase_success`
2. Verify последовательность отправленных событий == ожидаемая последовательность из xlsx `Dashboards`

### 8.3 Ручные сценарии (Acceptance из xlsx)
Запускать на test device с AppsFlyer **Test Device Reports** включёнными:

| # | Сценарий | Ожидаемые события |
|---|---|---|
| 1 | Cold start → onboarding → activation | `ast_app_open` (`is_new_user=true`) → `ast_onboarding_start` → `ast_onboarding_complete(steps_count, completion_seconds)` → `ast_auth_phone_submit` → `ast_auth_code_verify_success(is_signup=true)` → `ast_birth_data_complete` → `ast_activation_complete` → `ast_home_view` |
| 2 | Compatibility до покупки | `ast_compatibility_start` → `ast_compatibility_input_complete` → `ast_compatibility_generation_complete` → `ast_compatibility_result_view` → `ast_compatibility_limit_reached` → `ast_compatibility_paywall_view` → `ast_compatibility_paywall_click` → `ast_compatibility_purchase_start` → `ast_compatibility_purchase_success(af_revenue, af_currency)` |
| 3 | Coin spend на Anakra | `ast_anakra_start` → `ast_anakra_message_sent` → `ast_coin_spend_start(coin_amount, origin_surface=anakra)` → `ast_coin_spend_success` → `ast_anakra_response_view` |
| 4 | Sonnik до paywall (исчерпание лимита) | `ast_sonnik_start` → `ast_sonnik_dream_submit(dream_length_band)` → ... → `ast_sonnik_limit_reached(limit_type=requests, requests_left=0)` → `ast_sonnik_paywall_view` |
| 5 | Subscription покупка | `ast_subscription_paywall_view` → `ast_subscription_plan_select` → `ast_subscription_purchase_start` → `ast_subscription_purchase_success(af_revenue, af_currency)` |
| 6 | Payment timeout | `ast_*_purchase_start` → `ast_coin_purchase_expired(time_to_expire)` (без revenue) |
| 7 | PII-чек | Все события: открыть AppsFlyer raw data, убедиться что **нет** телефонов, имён, текстов снов/сообщений, дат рождения, partner names |
| 8 | Payload size (Acceptance 10.0) | Каждое событие < 1000 chars в params |
| 9 | Revenue de-duplication (Acceptance 4.0) | Одна успешная покупка → ровно один event с `af_revenue` |

---

## 9. Связи с дашбордами AppsFlyer (xlsx `Dashboards`)

Эти funnel-определения — финальные критерии успеха:

```
Activation:   ast_app_open → ast_onboarding_start → ast_onboarding_complete →
              ast_auth_phone_submit → ast_auth_code_verify_success →
              ast_birth_data_complete → ast_activation_complete → ast_home_view

Compatibility: ast_compatibility_start → ast_compatibility_input_complete →
               ast_compatibility_generation_complete → ast_compatibility_result_view →
               ast_compatibility_limit_reached/paywall_view →
               ast_compatibility_purchase_success

Natal chart:  ast_natal_start → ast_natal_birth_data_complete →
              ast_natal_generation_complete → ast_natal_result_view →
              ast_natal_paywall_view → ast_natal_purchase_success

Sonnik:       ast_sonnik_start → ast_sonnik_dream_submit →
              ast_sonnik_generation_complete → ast_sonnik_result_view →
              ast_sonnik_limit_reached/paywall_view → ast_sonnik_purchase_success

Anakra:       ast_anakra_start → ast_anakra_message_sent → ast_anakra_response_view →
              ast_anakra_limit_reached/paywall_view → ast_anakra_purchase_success

Coins:        ast_coin_paywall_view → ast_coin_package_select →
              ast_payment_method_select → ast_coin_purchase_start →
              success/failed/expired

Subscription: ast_subscription_paywall_view → ast_subscription_plan_select →
              ast_subscription_purchase_start → success/failed → restore
```

---

## 10. Рекомендация по архитектурному стилю имплементации

**Не правьте напрямую `AnalyticsFacade`.** Он сейчас — обобщённый layer. Все ast_*-события идут через **новый сервис `ProductAnalyticsService`**, который:

1. Содержит **типобезопасные методы** (не строки) для каждого ast_*-события. Пример из xlsx `Code Example`:

```dart
class ProductAnalyticsService {
  ProductAnalyticsService(this._facade);
  final AnalyticsFacade _facade;

  // Хардкод-таблица из xlsx — public для тестов
  static const Map<String, String> astToCanonical = {
    'ast_compatibility_start': 'funnel_start',
    'ast_compatibility_input_complete': 'funnel_step_complete',
    // ... 95 more
  };

  // Inferable из имени
  String? _funnelTypeFor(String astEvent) {
    if (astEvent.startsWith('ast_compatibility_')) return 'compatibility';
    if (astEvent.startsWith('ast_natal_')) return 'natal_chart';
    // ...
    return null;
  }

  Future<void> _track(String astEvent, {Map<String, dynamic>? params}) {
    final canonical = astToCanonical[astEvent];
    assert(canonical != null, 'Missing canonical mapping for $astEvent');
    final funnel = _funnelTypeFor(astEvent);
    return _facade.trackEvent(astEvent, params: {
      EventParams.canonicalEvent: canonical,
      if (funnel != null) EventParams.funnelType: funnel,
      ...?params,
    });
  }

  // ─────── Activation ───────
  Future<void> trackAppOpen({required bool isNewUser, EntrySurface? entrySurface}) =>
      _track(AstEvents.appOpen, params: {
        EventParams.isNewUser: isNewUser,
        if (entrySurface != null) EventParams.entrySurface: entrySurface.eventValue,
      });

  Future<void> trackOnboardingComplete({int? stepsCount, num? completionSeconds}) =>
      _track(AstEvents.onboardingComplete, params: {
        if (stepsCount != null) EventParams.stepsCount: stepsCount,
        if (completionSeconds != null) EventParams.completionSeconds: completionSeconds,
      });

  // ─────── Compatibility ───────
  Future<void> trackCompatibilityStart({required EntrySurface entrySurface}) =>
      _track(AstEvents.compatibilityStart, params: {
        EventParams.entrySurface: entrySurface.eventValue,
      });

  Future<void> trackCompatibilityPurchaseSuccess({
    required OfferType offerType,
    required PaymentType paymentType,
    required num revenue,
    required String currency,
    required EntrySurface originSurface,
    String? packageId,
    String? planId,
    String? paymentProvider,
  }) =>
      _track(AstEvents.compatibilityPurchaseSuccess, params: {
        EventParams.offerType: offerType.eventValue,
        EventParams.paymentType: paymentType.eventValue,
        EventParams.afRevenue: revenue,
        EventParams.afCurrency: currency,
        EventParams.originSurface: originSurface.eventValue,
        if (packageId != null) EventParams.packageId: packageId,
        if (planId != null) EventParams.planId: planId,
        if (paymentProvider != null) EventParams.paymentProvider: paymentProvider,
      });

  // ... остальные 95 методов
}
```

2. **`AnalyticsFacade` остаётся** — он используется для legacy `af_*` событий и для P1 generic-событий. Не дублировать логику.

3. **DI:** добавить в `di.dart`:
```dart
di.registerLazySingleton<ProductAnalyticsService>(
  () => ProductAnalyticsService(di.get<AnalyticsFacade>()),
);
```

4. **Точка вызова в UI** — всегда `di.get<ProductAnalyticsService>().trackXxx(...)`. Это унифицирует место и даёт автокомплит.

---

## 11. Открытые вопросы для пользователя/продакта

Ответы на эти вопросы нужны **до** старта T1. Часть вопросов можно решить параллельно с T1-T5 (фундамент), но они блокируют конкретные таски.

**Q1. Сосуществование af_* и ast_* событий.**
Спека прямо говорит «Replace/add ast_*» для P0-events (колонка `comment` xlsx, например R2). Понимать так, что **`af_*` остаются** (для backwards compat дашбордов), а `ast_*` отправляются **дополнительно** на ТУ ЖЕ точку? Подтвердите.

**Q2. Payment provider.** Сейчас приложение использует ArcoPay (видно по `ArcoPayApi` в `core/services/api/`). Но xlsx упоминает `yookassa` в примере. Что писать в `payment_provider`: `arcopay`, `yookassa`, оба? Зависит от того, какой именно процессор сейчас стоит в проде.

**Q3. Love deck / Kelt deck покупка — это revenue или internal coin spend?**
В коде они оплачиваются в **монетах** (`taro_cards_screen.dart:163-165`: `currency: 'coins'`). По спеке (R57 ast_tarot_purchase_success) предполагается revenue event с `af_revenue` + `af_currency`. Если покупка в монетах — это `ast_coin_spend_*` + `ast_tarot_card_reveal`, без revenue. Подтвердить.

**Q4. Natal chart покупка — где происходит сейчас?**
В `natal_card_screen.dart` есть `natalChartUnlockClick` (стр. 87), но самого checkout flow для натальной карты в коде я не вижу. R31-R33 (`ast_natal_purchase_*`) — куда их сейчас можно прицепить? Возможно, покупка идёт через общий subscription_screen?

**Q5. `ast_payment_method_select` (R83).**
Есть ли в UI экран выбора способа оплаты (карта / СБП / Apple Pay)? Если ArcoPay сам показывает payment provider'у — это off-app событие и его невозможно отловить. В этом случае — пропустить или отправлять при открытии payment URL.

**Q6. Restore purchases (R89..R91).**
В коде не нашёл UI «Restore purchases». На iOS это обязательное требование App Store для подписок. Есть ли соответствующий callback в коде? Если нет — это **scope creep**, может быть отдельной задачей.

**Q7. Push notifications.**
`ast_notification_permission_result` (P1). Есть ли в проекте код запроса push-permission? Не нашёл `firebase_messaging` permission flow. Если push не реализован — этот event пока пропустить.

**Q8. Funnel type для shop.**
В xlsx `Dictionaries` есть `funnel_type=shop` и `=profile`, но они не используются ни в одном P0-событии (только `profile_view`, `shop_view`). Уточнить: нужно ли `funnel_type` на `ast_profile_view` / `ast_shop_view`, или адаптер инферит автоматически (что предполагает мой проект `ProductAnalyticsService`)?

---

## 12. Acceptance checklist (из xlsx, лист `Acceptance`)

Финальная проверка перед merge:
- [ ] 1.0 Все P0 события имплементированы или явно помечены N/A
- [ ] 2.0 Все P0 события видны в AppsFlyer test device reports
- [ ] 3.0 Revenue корректно отображается в дашбордах AppsFlyer
- [ ] 4.0 Нет дублирования revenue (одна транзакция = один revenue event)
- [ ] 5.0 Адаптер маппит каждое `ast_*` → `canonical_event`
- [ ] 6.0 Адаптер инферит `funnel_type` где возможно
- [ ] 7.0 Каждое purchase/internal-spend событие включает `offer_type` и `payment_type`
- [ ] 8.0 События атрибутируются к источнику/кампании (уже работает через `AttributionService`)
- [ ] 9.0 Нет PII / free-text в payload
- [ ] 10.0 Каждое событие < 1000 chars

---

## 13. Краткая дорожная карта (для PM / репорта вверх)

| Этап | Задачи | Оценка |
|---|---|---|
| 1. Фундамент | T1-T5 | 1-2 дня |
| 2. Auth + Onboarding + Home | T6-T8 | 2 дня |
| 3. Core funnels (Compatibility, Natal, Sonnik, Anakra) | T9-T12 | 3-4 дня |
| 4. Content (Tarot, Runes, Moon, Affirmations) | T13-T14 | 2-3 дня |
| 5. Payments (Coins, Subscription, Restore) | T15-T17 | 2-3 дня |
| 6. Profile / shop / P1 | T18-T19 | 1 день |
| 7. Аудит revenue + полировка | T20-T22 | 1 день |
| 8. QA / acceptance | манульный test pass | 2 дня |

**Итого: ~14-17 рабочих дней одного разработчика.**
