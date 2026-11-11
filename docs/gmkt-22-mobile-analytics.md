# GMKT-22: мобильная аналитика

Мобильная часть плана
`../asteria-back/docs/superpowers/plans/2026-09-10-gmkt-22-analytics.md`.
Этот контракт заменяет прежнюю схему отправки всех событий только в AppsFlyer.
Документ описывает мобильный контракт и соответствия AF. Серверная доставка
описана отдельно в `../asteria-back/docs/analytics/backend.md`.

## Обязательное условие production-выпуска

**Не выпускать эту сборку, пока серверные AF S2S и private channel не настроены и
не проверены сквозным тестом.** Клиентские revenue-события удалены независимо от
флага нового канала. Выключенный флаг не возвращает старую отправку денег в SDK:
иначе новый релиз создаст разрыв в финансовой атрибуции до готовности сервера.

Для согласованного тестирования через TestFlight используется отдельная beta-сборка:
собственная аналитика включена, окружение `test`, денежные события проверяются
в BigQuery, AppsFlyer S2S остаётся выключенным. Это не production-выпуск.
Проверенная конфигурация для TestFlight 1.0.5 (56):

```sh
flutter build ipa --release --build-name=1.0.5 --build-number=56 \
  --dart-define=ASTERIA_ANALYTICS_ENABLED=true \
  --dart-define=ASTERIA_ANALYTICS_ENVIRONMENT=test
```

До загрузки проверить встроенный `.env`: `ASTERIA_BACKEND_URL`, `API_KEY`,
`APPSFLYER_API_KEY`, `APPSFLYER_IOS_APP_ID`. Значения секретов в git не добавлять.
После обработки Apple проверить доступ новой сборки у нужной группы тестировщиков.

Сбор и API-доставка по умолчанию выключены. После подтверждения координатора:

```sh
flutter build ipa --dart-define=ASTERIA_ANALYTICS_ENABLED=true \
  --dart-define=ASTERIA_ANALYTICS_ENVIRONMENT=production
```

Для Android те же defines передаются в `flutter build appbundle`. Для тестовых
сборок используется `environment=test`; TestFlight сам по себе не означает production.
Адрес и API key берутся из существующих `ASTERIA_BACKEND_URL` и `API_KEY`.
Версия читается из установленного пакета через `PackageInfo.fromPlatform()`:
`version+buildNumber`. Нет фиксированного fallback `1.0.5+55` или ручного version define.
Отсутствующие/невалидные метаданные выключают сбор с `app_version_unavailable`.
`package_info_plus` объявлен прямой зависимостью; platform/lock-файлы не менялись.

## Инициализация и контекст

DI регистрирует `AnalyticsStore`, `AnalyticsTransport`, `DurableAnalytics`,
`AnalyticsLifecycle`, facade, route observer и attribution service.
Hive открывается отложенно, только при включённом сборе. Ошибка открытия analytics
box не останавливает запуск приложения: сервис переходит в degraded-состояние,
повторяет открытие и после восстановления сохраняет диагностические счётчики.
События во время недоступности диска не считаются сохранёнными; учитывается
`degraded_dropped_events`. Такие счётчики находятся в памяти до восстановления:
их сохранность при убийстве процесса с неработающим диском не гарантируется.
Повреждённые boxes не удаляются автоматически ради запуска аналитики.

Локальная инициализация и retry запускаются до ожидания AppsFlyer/ATT.
`ProductAnalyticsService` остаётся типизированным API для экранов;
`AnalyticsFacade` централизованно преобразует имена и очищает параметры.
Продуктовые вызовы ждут локальную запись, но не сеть и не SDK.

Installation context содержит UUID и отдельный случайный 256-битный токен
(32 байта, base64url). Все analytics-запросы используют:

```text
Authorization: Bearer <API_KEY>
X-Analytics-Token: <installation token>
```

Сначала `/api/v2/analytics/installations` получает
`{installation_id, platform, environment, app_version}`. Только после успешного
bootstrap запускаются identify, события, attribution и diagnostics. Ответ 503 не
подтверждает регистрацию; повтор использует прежние installation ID и токен.
Первоначальные platform/environment закрепляются в контексте. Несовпадение в
следующей сборке блокирует сбор/доставку с `installation_context_mismatch`.
Для test и production нужны отдельные установки, а не переименование старых событий.

`/identify` получает **только** `{installation_id}` в body и проверенную сессию в
`X-Asteria-User-Token`. Клиентский UID в body не передаётся. Сервер возвращает
неизменяемый случайный `identity_id`; перед сохранением проверяются текущий
аккаунт и возвращённый `user_id`. Идентификатор в событии фиксируется синхронно
до асинхронной записи. Logout, смена аккаунта и поздний identify не переписывают
очередь и не присваивают прежним анонимным событиям текущего пользователя.
Регистрация/profile остаются серверными фактами; клиент запускает identify после
существующего успешного серверного обновления. `first_open` всегда installation-level.

## Очередь и доставка

| Hive box | Содержимое | Срок/ограничение |
| --- | --- | --- |
| `analytics_events_v1` | Канонические envelopes, FIFO | 7 суток, 10 000 событий, 20 MiB UTF-8 JSON |
| `analytics_context_v1` | Installation credentials, identity, session/attempt, first-open marker, counters, pending diagnostic | Срок жизни установки |
| `analytics_attribution_v1` | Первый полный callback, SDK UID, revision/ACK/quarantine | Независимо от event queue; без автоматического TTL |

Сначала удаляются истёкшие записи, затем старейшие низкоприоритетные views,
затем остальные; first-open/auth/checkout защищены более высоким приоритетом.
Compaction освобождает удалённые записи. Лимит 20 MiB относится к JSON содержимому,
не включает служебный формат Hive и временные файлы compaction.

First-open envelope сохраняется до enqueue: повтор после падения использует тот
же UUID. После первого enqueue expiry/overflow не создают новый first-open.
Для уже существующей установки при первом обновлении это первое наблюдение новой
pipeline, а не доказательство даты первоначальной установки из магазина.

Сессия сохраняется при отсутствии менее 30 минут. Pause и foreground checkpoint
сохраняют активность; restart учитывает прежнее время. Запросы генерации и checkout
имеют attempt UUID в рамках session/account. History view может не иметь attempt.

`/events/batch` содержит ровно `installation_id` и массив до 100 событий с полями:
`event_id`, `event_name`, `schema_version`, `occurred_at`, `session_id`, `identity_id`,
`platform`, `app_version`, `environment`, `payload`. Клиентский `user_id` отсутствует.
Удаляются только явно подтверждённые IDs из отправленного batch. 503/429,
сетевой сбой, потерянный/неполный/невалидный ACK сохраняют исходные события.
Retry: база 15 секунд, exponential backoff до 300 секунд, jitter 0-4 секунды;
resume запускает ближайшую попытку. За цикл отправляется до 10 обычных batches.
Каналы после bootstrap независимы. Невалидный обычный batch не отбрасывается
молча: требуется исправление причины либо срабатывает семидневный TTL.

## Attribution

SDK UID getter и conversion-data callback независимо обновляют durable revision.
UID может отправляться раньше callback с `raw_payload: {}`. Первый conversion
callback сохраняется **целиком**, включая внешний envelope и неизвестные поля;
повторные callbacks не заменяют оригинал. Старый ACK не удаляет новую revision.
Только conversion data задаёт первоначальную атрибуцию. App-open, deep-link и
re-engagement не меняют initial raw. `is_first_launch=false` может означать
кэшированную исходную установку и не интерпретируется как retargeting.
Отсутствие campaign не объявляется Organic.

Приложение и backend извлекают поля conversion из `data` или `payload`,
если значение является объектом; callback без обёртки также поддерживается.
При наличии обеих обёрток приоритет у `data` для совместимости.
Полный исходный callback сохраняется отдельно без изменений. `media_source`
сохраняется и без `campaign_id`; ранее пустая серверная атрибуция может быть
дополнена повторной обработкой исходного callback. Уже установленный initial
источник не заменяется последующим источником или retargeting.

Сервер ограничивает raw JSON 64 KiB, считая ASCII-escaped JSON как Python.
Превышение сохраняет raw без обрезания, но переводит revision в quarantine:
`attribution_oversized`/`attribution_blocked`. Raw не считается подтверждённым
и не повторяется бесконечно. SDK UID может доставляться отдельно с пустым raw,
обычные события продолжают отправляться. 413/422 дают `attribution_rejected`.

## Платёжная корреляция

**HTTP-контракт: верхнеуровневый `attempt_id`, не `analytics_context`.**
Apple/Google verify и рабочий ArcPay one-time checkout отправляют этот необязательный UUID.
При выключенном сборе или отсутствии подходящего context поле опускается.
Полный `{installation_id, identity_id, session_id, attempt_id}` хранится только
локально: captures до store sheet, запись PendingPurchase, неизменный replay после
restart. Совпадающий повтор receipt сохраняет context; restore/renewal без
совпадающей pending purchase не получает attempt текущего пользователя.
Старые Hive записи без поля читаются как раньше.

Для реального UI порядок: `paywall_viewed <= offer_selected <= checkout_started`.
Если UI не прислал выбор, durable слой фиксирует выбранный продукт перед checkout;
уже полученный выбор не дублируется. `PaywallPurchasing` больше не создаёт поздний
offer. Полученный checkout context помечается использованным. Повторный fallback
или другой product ID создаёт новый attempt, не подхватывает прошлую покупку.

Read-only contract tests проверяют настоящие Dio bodies через текущие backend
`AppleVerifyRequest`, `GoogleVerifyRequest`, `ArcPayCheckoutRequest`, включая
сохранение `attempt_id` после validation, а не только принятие неизвестного поля.
Рабочий `SubscriptionScreen` использует `_ArcPayOneTimeProPlans` ->
`ArcPayCheckoutCubit` -> `/api/v2/payments/arc-pay/checkout`: one-time PRO входит
в проверенный контракт. `_ArcPaySubscriptionPlans` не используется; recurring
`/subscriptions/checkout` является legacy и находится вне GMKT-22 mobile scope.
Его API, cubit и baseline-тесты оставлены без analytics-изменений. Расширение
legacy backend не требуется; backend не редактировался.

## События и приватность

`AnalyticsTaxonomy` задаёт явный mapping и allowlist параметров: enum, ограниченные
числа, bool, статические маршруты, product IDs из каталога. В продуктовые события
не проходят имена, контакты, данные рождения, текст сна/сообщения, exception text,
платёжные payloads, токены, произвольные строки, revenue/currency/price. Сервер
допускает product price, но клиент консервативно его не отправляет. Raw attribution
доступен только отдельному endpoint и не логируется. SDK debug logging выключен.

| Каноническое событие | Мобильный источник |
| --- | --- |
| `first_open`, `session_started` | Durable lifecycle |
| `screen_viewed` | Реальный GoRouter match, push/pop/go/replace, вкладки Home; без query |
| `onboarding_step_viewed`, `auth_result` | Существующие onboarding шаги и результаты email verification |
| `feature_action_started` | Реальные Compatibility/Natal/Horoscope requests; Sonnik submit; Anakra send; Tarot/Runes insight/refresh; Love/Kelt buy/refresh; загруженная статья открыта |
| `feature_result_viewed` | Явный показ результата, успешный видимый ответ, открытые карты/руна/affirmation, unlocked horoscope, видимый lunar day, конец статьи |
| `feature_action_failed` | Ошибка реального запроса/генерации, показанная ошибка Anakra |
| `paywall_viewed`, `offer_selected` | Явные paywalls и package/plan choice, выбор до checkout |
| `checkout_started`, `checkout_outcome` | Purchase intent и native pending/failed/cancelled; не денежные факты |
| `analytics_queue_dropped` | Ограниченный snapshot потерь и recovery counters |

Все `ast_*_start`, обозначающие вход на экран, исключены из action attempts.
Успешная генерация сама по себе не означает показ результата. Legacy-дубли
исключены: `rune_view` владеет результатом руны, `ast_runes_reveal` игнорируется;
yearly horoscope paywall не создаёт второй moon paywall. Moon не расходует marker
при скрытой предзагрузке IndexedStack, учитывает данные после видимого frame.
Anakra различает `result/failed/stale/ignored`, проверяет identity revision,
активную auth-сессию, mounted/route visibility/lifecycle после await. Старый запрос
не создаёт результат или ошибку нового аккаунта, включая A -> B -> A.
Article open/read разделены; title/text/article IDs в params отсутствуют.

Клиентский AF mapping и allowlist находятся в `AppsFlyerEvents`.
Четыре прежних события сохранены: `af_tutorial_completion`, `af_initiated_checkout`,
`ast_paywall_view`, `ast_first_useful_result`. First useful имеет атомарный marker
на installation, а не на профиль: greeting, failure, profile completion и просто
окончание генерации его не занимают. Marker ставится до SDK-вызова: это at-most-once
invocation, не гарантия доставки провайдером после crash/SDK failure.
`af_complete_registration`, `ast_profile_completed`, trial/payment/refund принадлежат
серверу. Legacy `ast_activation_complete` не отправляется SDK; SDK adapter повторно
фильтрует даже вызовы в обход facade. Клиент не отправляет revenue ни при одном флаге.

### Соответствия AppsFlyer

Названия и payload нашей аналитики не изменены. AF получает смысловой аналог,
а не второе событие с каноническим именем. Например, открытие профиля создаёт
`screen_viewed` в нашей аналитике и только `ast_profile_view` в AF.

| Наша аналитика | AppsFlyer | Условие |
| --- | --- | --- |
| `first_open` | `ast_first_open` | Первый наблюдаемый запуск установки |
| `session_started` | `ast_app_open` | Новая сессия, включая возврат после 30 минут |
| `screen_viewed` | `ast_home_view`, `ast_profile_view`, `ast_shop_view` | Главная, профиль, магазин |
| `screen_viewed` | `ast_compatibility_start`, `ast_natal_start`, `ast_sonnik_start`, `ast_anakra_start`, `ast_tarot_start`, `ast_runes_start`, `ast_moon_start`, `ast_horoscope_start`, `ast_affirmations_start` | Вход на соответствующий экран |
| `screen_viewed` | Отдельное имя из таблицы ниже | Остальные разрешённые маршруты |
| `onboarding_step_viewed` | `ast_onboarding_step_view` | Показ шага |
| `auth_result` | `ast_auth_code_verify_success`, `ast_auth_code_verify_failed` | Результат проверки кода |
| `feature_action_started` | `ast_sonnik_dream_submit`, `ast_anakra_message_sent`, `ast_article_open` | Отправка сна, сообщения, открытие статьи |
| `feature_action_started` | `ast_feature_action_start` | Другие действия; параметр `feature` |
| `feature_result_viewed` | `ast_compatibility_result_view`, `ast_natal_result_view`, `ast_sonnik_result_view`, `ast_anakra_response_view` | Показ соответствующего результата |
| `feature_result_viewed` | `ast_tarot_card_reveal`, `ast_runes_reveal`, `ast_horoscope_result_view`, `ast_moon_result_view`, `ast_affirmation_card_view`, `ast_love_deck_card_view`, `ast_kelt_deck_card_view`, `ast_article_read` | Карты, руны, прогнозы, аффирмации, конец статьи |
| `feature_result_viewed` | `ast_feature_result_view` | Резерв для остальных feature |
| `feature_action_failed` | `ast_feature_action_failed` | Ошибка действия |
| `feature_*` с `feature=star_fair` | `ast_star_fair_start`, `ast_star_fair_resume`, `ast_star_fair_choice`, `ast_star_fair_replay`, `ast_star_fair_complete`, `ast_star_fair_reading_view`, `ast_star_fair_reading_failed` | Соответствующее действие игры; без второго generic-события |
| `paywall_viewed` | `ast_paywall_view` | Все paywall, включая игру |
| `offer_selected` | `ast_coin_package_select`, `ast_subscription_plan_select`, `ast_offer_select` | Выбор пакета, подписки, другого предложения |
| `checkout_started` | `af_initiated_checkout` | Начало оформления |
| `checkout_outcome` | `ast_checkout_outcome` | Результат клиентского checkout; не доказательство списания |
| `restore_started` | `ast_purchase_restore_click` | Запрос восстановления |
| `restore_outcome` | `ast_purchase_restore_success`, `ast_purchase_restore_empty`, `ast_purchase_restore_failed` | Результат восстановления; не новая покупка |

### Имена экранов в AF

BigQuery сохраняет `screen_viewed` и параметр `screen`. Только в AF-копии
экранного события `screen` удаляется: экран определяется стабильным именем.
Остальные параметры сохраняются. Таблица `AppsFlyerEvents.screens` покрывает
все разрешённые экраны; существующие специальные имена выше не переименованы.
Новые соответствия закреплены явно, имена не строятся из произвольных URL.

| Экран (`screen` в BigQuery) | Событие AF |
| --- | --- |
| `/about-us` | `ast_about_us_view` |
| `/achievements` | `ast_achievements_view` |
| `/anakra/requests-left` | `ast_anakra_requests_left_view` |
| `/anakra/subscription` | `ast_anakra_subscription_view` |
| `/article` | `ast_article_view` |
| `/auth/email` | `ast_auth_email_view` |
| `/auth/email/code` | `ast_auth_email_code_view` |
| `/auth/login` | `ast_auth_login_view` |
| `/auth/personal-info` | `ast_auth_personal_info_view` |
| `/balance` | `ast_balance_view` |
| `/balance-history` | `ast_balance_history_view` |
| `/coins-paywall` | `ast_coins_paywall_view` |
| `/compatibility/create` | `ast_compatibility_create_view` |
| `/compatibility/history` | `ast_compatibility_history_view` |
| `/compatibility/loaded` | `ast_compatibility_loaded_view` |
| `/compatibility/requests-left` | `ast_compatibility_requests_left_view` |
| `/compatibility/subscription` | `ast_compatibility_subscription_view` |
| `/home/astrology` | `ast_home_astrology_view` |
| `/home/personal` | `ast_home_personal_view` |
| `/kelt-deck` | `ast_kelt_deck_view` |
| `/love-deck` | `ast_love_deck_view` |
| `/onboarding` | `ast_onboarding_view` |
| `/payments` | `ast_payments_view` |
| `/payments-settings` | `ast_payments_settings_view` |
| `/profile/payment` | `ast_profile_payment_view` |
| `/settings` | `ast_settings_view` |
| `/social/feed` | `ast_social_feed_view` |
| `/social/notifications` | `ast_social_notifications_view` |
| `/social/post` | `ast_social_post_view` |
| `/social/profile` | `ast_social_profile_view` |
| `/social/search` | `ast_social_search_view` |
| `/social/settings` | `ast_social_settings_view` |
| `/sonnik/create` | `ast_sonnik_create_view` |
| `/sonnik/history` | `ast_sonnik_history_view` |
| `/sonnik/loaded` | `ast_sonnik_loaded_view` |
| `/sonnik/requests-left` | `ast_sonnik_requests_left_view` |
| `/sonnik/subscription` | `ast_sonnik_subscription_view` |
| `/star-fair` | `ast_star_fair_view` |
| `/subscription` | `ast_subscription_view` |

Это имена посещений экранов. Отдельное бизнес-событие `paywall_viewed` по-прежнему
отправляется как `ast_paywall_view`; покупки и другие действия не переименованы.
`ast_screen_view` остаётся резервом для неизвестного экрана, но ни один маршрут
текущего разрешённого списка его не использует. Исторические данные AF не меняются.

Повторная отправка локальной очереди и её восстановление после перезапуска не
создают AF-событий. AF получает уведомление о новом факте после локальной записи,
включая автоматически сформированные `offer_selected` и `checkout_started`.
Для полного потока, включая lifecycle и автоматический выбор предложения, нужны
прежние build defines выше. Если собственный сбор выключен или локальная запись
не удалась, явные пользовательские сигналы всё равно идут в AF, но без correlation
ID, которые не были сформированы. Это не означает сохранение события в BigQuery.
В AF передаются безопасные `event_id`, `session_id`, `attempt_id`, `restore_id`,
окружение и версия, когда они есть. `event_id` помогает сверять каналы, но не является
обещанием дедупликации со стороны AppsFlyer.

Дополнительные уже существующие сигналы направляются только в AF:

| AF-события | Действие |
| --- | --- |
| `ast_onboarding_start`, `ast_onboarding_step_complete`, `ast_onboarding_skip`, `af_tutorial_completion` | Начало, завершение шага, пропуск, завершение онбординга |
| `ast_auth_start`, `ast_auth_code_request` | Начало входа, запрос кода |
| `ast_home_card_view`, `ast_home_card_click` | Существующий сигнал карточки на видимой вкладке, нажатие; это не измерение доли карточки в viewport |
| `ast_profile_menu_click`, `ast_shop_item_select`, `ast_account_logout`, `ast_account_delete` | Меню, выбор товара, выход, удаление аккаунта |
| `ast_compatibility_input_complete`, `ast_natal_birth_data_complete` | Завершение ввода без самих персональных данных |
| `ast_compatibility_generation_complete`, `ast_natal_generation_complete`, `ast_sonnik_generation_complete`, `ast_moon_generation_complete` | Успешное завершение генерации, отдельно от показа результата |
| `ast_natal_section_view`, `ast_anakra_quick_action_click`, `ast_affirmation_engagement`, `ast_content_engagement`, `ast_tarot_spread_start` | Раздел, быстрое действие, взаимодействие, начало расклада |
| `ast_compatibility_limit_reached`, `ast_sonnik_limit_reached`, `ast_anakra_limit_reached`, `ast_tarot_locked_view`, `ast_runes_locked_view`, `ast_affirmation_locked_view` | Лимит или закрытый контент |
| `ast_compatibility_paywall_click`, `ast_natal_paywall_click`, `ast_sonnik_paywall_click`, `ast_anakra_paywall_click`, `ast_horoscope_paywall_click`, `ast_subscription_paywall_click`, `ast_love_deck_paywall_click`, `ast_kelt_deck_paywall_click` | Нажатие CTA |
| `ast_coin_spend_start`, `ast_coin_spend_failed`, `ast_payment_method_select`, `ast_subscription_manage_click` | Начало/ошибка траты внутренних монет, выбор способа, управление подпиской |
| `ast_error_state_view`, `ast_notification_permission_result` | Существующий вызов показа ошибки или результата разрешения |

Allowlist не создаёт новые UI-вызовы там, где их пока нет. Инициализация скрытой
вкладки не считается просмотром. Home/Personal повторно проверяют доступные карточки
после видимого кадра при возвращении; marker показа ставится только на своей
активной вкладке. Эти сигналы не измеряют фактическую долю карточки в viewport.
Начальные `ast_moon_tab_view` и natal `overview` не включены: сейчас они повторяют
открытие экрана/показ результата, а не отдельное переключение раздела.
Ранние `ast_tarot_card_reveal`/`ast_runes_reveal` не используются как источники:
AF-имя формируется только из уже проверенного канонического показа результата.
Диагностика очереди, identity bridge и raw attribution не становятся AF-событиями.

### Серверные события AF

| Наша аналитика | AppsFlyer |
| --- | --- |
| `registration_completed` | `af_complete_registration` |
| `profile_completed` | `ast_profile_completed` |
| `trial_started` | `ast_subscription_trial_started` |
| `payment_succeeded` | `ast_subscription_purchase_success` для PRO, иначе `ast_coin_purchase_success` |
| `payment_refunded` | `ast_payment_refunded` |
| `subscription_state_changed` | `ast_subscription_state_changed` |
| `stars_spent` | `ast_coin_spend_success` |
| `stars_refunded` | `ast_coin_spend_refunded` |

Только подтверждённые payment/refund несут `af_revenue` и `af_currency`.
Продления сохраняют `billing_reason`, ArcPay one-time PRO сохраняет `access_mode`.
Внутренние монеты не считаются денежной выручкой. Коррекции сумм обогащают исходный
платёж, а не создают второе денежное событие. Все серверные события требуют
отдельно настроенного и включённого S2S; новая мобильная сборка его не включает.
Порядок закрытия старого AF backlog описан в `../asteria-back/docs/analytics/backend.md`.

## Восстановление покупок

Нативное восстановление отдельно от оформления новой покупки:

- `restore_started`: `restore_id` (случайный UUID на каждую попытку).
- `restore_outcome`: тот же `restore_id`, `outcome=success|empty|failed`.
  Для завершённой проверки есть `restored_count`, число уникальных товаров.
  `empty` означает, что магазин не вернул покупок, а не ошибку магазина/сервера.
- События формируются по состояниям PaywallCubit, проходят AnalyticsFacade,
  локальную очередь и обычный backend/Pub/Sub/BigQuery канал. Повторная доставка
  сохраняет event_id; новая попытка получает новый restore_id.
- Restore не создаёт `checkout_outcome`, не использует прежний checkout attempt_id,
  не отправляет клиентскую выручку. В AF идут только неденежные события восстановления
  из таблицы выше. Проверка ранее
  учтённой транзакции использует существующую серверную дедупликацию платежей.
- Ошибка проверки хотя бы одного товара даёт `failed`, а не ложный полный успех;
  уже подтверждённые права при этом не откатываются. Ошибки SDK и таймаут также
  дают `failed`; повтор доступен через ту же кнопку.

Backend должен разрешать оба имени до установки клиентской сборки с этими событиями.
Для BigQuery не нужна миграция: параметры находятся в существующем JSON payload.

## Диагностика потерь

Локально: `di.get<AnalyticsStore>().diagnostics` показывает count/bytes очереди,
storage availability, attribution pending/blocked и cumulative counters.
**Нельзя печатать `AnalyticsStore.context`, токены или raw callback.**

При восстановлении сети `analytics_queue_dropped` отправляет payload:

```json
{
  "snapshot_version": 1,
  "dropped_expired": 0,
  "dropped_overflow": 0,
  "degraded_dropped_events": 0,
  "storage_open_failures": 0,
  "storage_recoveries": 0,
  "attribution_oversized": 0,
  "attribution_rejected": 0
}
```

Это накопительные totals на installation, не дельты. Значения ограничены
`0..9007199254740991`; полностью нулевой или неизменившийся snapshot не отправляется.
Один pending envelope сохраняется отдельно в context: стабильные UUID/time/payload
до ACK, `identity_id=null`. Он не занимает обычную очередь, не вызывает eviction
и сам не увеличивает loss counters. Новые потери во время retry входят в следующий
snapshot. Сервер дедуплицирует по event ID; для отчёта нужны последние/MAX totals
по installation, **не SUM snapshots**. Одна новая snapshot-попытка на flush cycle.
`diagnostic_delivery_failures` остаётся локальным счётчиком и не создаёт feedback loop.

Дополнительные локальные counters: `bootstrap_failures`, `identify_failures`,
`event_delivery_failures`, `attribution_delivery_failures`, `storage_failures`,
`installation_context_mismatch`, `app_version_unavailable`.

## Проверки и оставшиеся условия

Фактический локальный результат 2026-09-11, после review fixes:

- `flutter test --no-pub --reporter expanded`: **443 passed**, exit 0, включая
  четыре read-only backend contract tests. Свежий полный прогон после исключения
  legacy recurring wiring; из прежних 444 удалён только тест этой корреляции.
- Scoped `flutter analyze --no-pub`: **No issues found**, exit 0. Проверены durable
  analytics, facade, route/attribution, payments, DI/SDK/app, Anakra, MoonScreen,
  payment/subscription cubits и соответствующие новые/изменённые тесты.
  После исключения legacy wiring повторная scoped-проверка durable analytics,
  DI, payments, subscription cubits и соответствующих тестов также чистая.
- Полный `flutter analyze --no-pub`: **107 info**, exit 1; errors/warnings нет.
  Это существующие style infos, включая прежние UI-конструкторы. Они не скрывались
  настройками и не исправлялись вне scope.
- `git diff --check`: чисто. GitNexus `detect_changes(scope=all)`: HIGH,
  33 tracked files, 91 indexed symbols, 7 affected flows. Новые untracked файлы
  не входят в этот графовый подсчёт и проверены отдельно.

Тесты охватывают restart/Hive persistence, identity/logout/switch, stale identify,
7d/10k/20MiB и priority overflow, retries/partial ACK/503, sessions, independent SDK,
raw attribution/revisions/quarantine, taxonomy/privacy/revenue suppression,
ordered checkout и one-use context, native outcomes, route/tab transitions,
реальные widget flows статьи, Moon и Anakra, degraded storage и loss snapshots.

В отдельном репозитории приложения `flutter test` проверяет клиентские соответствия
AppsFlyer по таблице выше и по [контракту социальных действий](social-client-report.md).
Если задан путь к серверу или рядом есть папка `../asteria-back`, обычный
`flutter test` дополнительно сверяет клиент с серверной моделью.
Перед релизом дополнительно проверьте все события, которые принимает версия сервера
для этого релиза. Из корня мобильного проекта выполните:

```sh
ASTERIA_BACKEND_PATH=/path/to/asteria-back flutter test --no-pub test/core/analytics/backend_client_events_contract.dart
```

Команда использует стандартный `python3` и читает объявление `CLIENT_EVENTS`
из файла модели сервера. При отсутствии файла или изменении формата объявления
она завершается ошибкой. Для соседнего
`../asteria-back` переменную можно опустить. Также поддерживается `GMKT22_BACKEND`.

`backend_contract_test.dart` использует соседний backend venv (`GMKT22_BACKEND`
переопределяет путь), только чтение и `python -B`. Analytics-модели импортируются
напрямую; payment request classes извлекаются AST из исходника без запуска Firebase
и payment clients. При отсутствии venv тест явно skipped. Это проверка текущих
моделей и сериализации, не живой HTTP/auth/server/provider E2E.
Перед handoff обязательны свежие полный `flutter test`, scoped analyze и diff check.
Общий analyze содержит прежние UI-style infos; unrelated style здесь не исправляется.

GitNexus HIGH/CRITICAL для facade/DI/route/SDK были переданы координатору до правок.
Новые неиндексированные файлы проверены напрямую и тестами. Реализация сохранена
локально в codex/gmkt-22-analytics. Push и deploy не выполнялись.

Оставшиеся реальные проверки перед выпуском:

1. Включённый test backend/cloud: bootstrap -> verified identify -> Pub/Sub ->
   BigQuery, immutable environment, дедупликация, loss quality report, закрытый raw
   dataset; реальные 503/429/offline recovery без ложного ACK.
2. iOS/Android: cold start, kill/restart, airplane mode, background/resume через
   30 минут, logout/switch с очередью. Сверить исходные identity/event/attempt IDs.
3. Проверить установленную version/build, environment, reinstall/backup и правила
   хранения installation secret в sandbox. Ошибка диска не должна блокировать app.
4. AppsFlyer conversion/UID в разном порядке, ATT grant/deny/delay, offline callback,
   Organic/unattributed и re-engagement без перезаписи initial attribution.
5. Store sandbox и ArcPay: order/verify attempt -> серверный факт, pending/cancel/
   success/restore/renewal/refund, server AF deduplication; отсутствие client revenue
   в кабинете. Для PRO проверить рабочий one-time checkout, не legacy recurring.
6. Пройти реальные feature result/error/paywall и history flows. Полной widget-матрицы
   Compatibility/Natal/Sonnik/Horoscope/Tarot/Runes AI/entitlement permutations нет:
   mapping и request wrapper проверены, это не замена device walkthrough.

P1 menu clicks, notification permissions, impressions, copy/share не входят в
реализованную базовую каноническую таксономию. Живой backend, device/store-console
и облачная доставка локальными тестами не подтверждены.
