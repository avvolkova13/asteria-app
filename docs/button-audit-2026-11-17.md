# Аудит кнопок Asteria — 17 ноября 2026

## Охват

Проверены исходники всех 28 разделов приложения, общий UI kit, location и utils: 121 файл с 478 объявлениями обработчиков действий. Это число обработчиков, а не уникальных кнопок. Проверялись поверхности, иконки, локальные реализации и состояния, а не только имя класса кнопки.

Разделы: about_us, achievements, affirmation, anakra_chat, article, auth, balance, coins_paywall, compatibility, home, horoscope, kelt_deck, love_deck, monetization, natal_card, onboarding, payments, payments_settings, profile_avatar, profile_flow, runes, scenarios, settings, shop, sonnik, splash, subscription, taro_cards.

Два независимых read-only прохода (button_audit и plans_review) разделили исходники; основной агент объединил исправления и проверил результат. Для оценки согласованности использован Impeccable. Существующие текстовые ссылки и карточки действий сохранены в своих ролях: им не навязывалась форма основной CTA.

## Исправления

- Анакре: старая контурная иконка отправки заменена объёмной золотой стрелкой; пустое поле и занятое состояние сохраняют блокировку отправки.
- Авторизация: checkbox и radio приведены к актуальным поверхностям; длинные подписи переносятся, disabled radio визуально отличается.
- Общая очистка поля и выход из профиля: область нажатия увеличена до 44 точек.
- Покупка: плоская рамка счётчика заменена общей объёмной поверхностью. Плюс и минус используют одинаковые золотые иконки и размеры, недоступный минус различается состоянием.
- Подтверждение города: вторичное действие использует актуальную outlined-кнопку вместо прозрачной старой реализации.
- Справка в Кельтском кресте: убрано старое подчёркивание; в четырёх разделах раскладов снято обрезание длинных подписей.
- Сонник: у кнопки баланса восстановлено действие для VoiceOver.
- CustomCheckbox, SettingsListTile и PurchaseOfferButton обновлены в общем UI kit, включая светлое оформление и крупный текст. У трёх прежних реализаций нет живых вызовов в текущих экранах; их проверяли отдельными widget tests/render, а не выдавали за просмотренные экраны.

Основные файлы: core/ui_kit/widgets/{custom_checkbox,purchase_offer_button,settings_list_tile,text_input_field_widget}.dart; core/location/widgets/current_location_controls.dart; features/anakra_chat/presentation/widgets/anakra_composer.dart; features/auth/presentation/widgets/{inputs_section_widget,radio_button_group}.dart; features/home/presentation/screens/profile_screen.dart; features/shop/presentation/widgets/purchase_modal_sheet.dart; features/sonnik/presentation/widgets/sonnik_layout.dart; экраны kelt_deck, love_deck, runes, taro_cards.

## Проверки

- 58 widget tests прошли: button_refresh, custom_button, adaptive_controls, lotus_icon_surface, city_selection_screen, radio_button_group, email_only_auth_surface, anakra_design, purchase_modal_sheet, modal_gallery.
- Проверены оба оформления, ширина 320, увеличенный текст до 2.0 в соответствующих тестах, клавиатурное управление, callbacks и недоступные действия.
- Изображения реальных виджетов в тёмном и светлом оформлении просмотрены: длинные подписи и крупный текст помещаются.
- Анализ затронутой области: нет errors/warnings; остаются 86 info-сообщений анализатора.
- Debug iOS simulator build прошёл; новая сборка установлена на iPhone 16 iOS 18.2.
- На симуляторе визуально проверены активная/неактивная отправка, очистка поля и отсутствие текста после очистки; окно покупки, оформление кнопок, изменение количества 1 → 2 → 1 и пересчёт суммы. Отправка сообщений и покупка не выполнялись. В конце пользователь начал взаимодействовать с симулятором; дальнейшие действия агента прекращены.
- git diff --check: без ошибок.

## Ограничения и статус

Покрытие всех разделов — аудит кода. Не каждое платное, внешнее или разрушительное действие было вручную выполнено. Авторизация и неиспользуемые компоненты дополнительно проверены widget tests; независимого наблюдения за новым пользователем не проводилось. В проверенных визуальных вариантах незакрытых high/medium замечаний нет. Изменения локальные, без commit/push и публикации.
