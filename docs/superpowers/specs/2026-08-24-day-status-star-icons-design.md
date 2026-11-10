# Звёзды статуса дня во всём приложении

Дата: 2026-08-24
Статус: готово к продуктовой проверке перед implementation plan

## 1. Задача и бизнес-смысл

Во всех интерфейсах лунного календаря один и тот же бизнес-признак — статус дня — должен иметь единый визуальный язык:

- `favorable` / благоприятный — зелёная улыбающаяся звезда;
- `neutral` / нейтральный — жёлтая нейтральная звезда;
- `unfavorable` / неблагоприятный — красная грустная звезда.

Сейчас часть интерфейса использует старые круглые смайлы, часть дизайна — новые звёзды. Это создаёт две конкурирующие системы обозначений для одного понятия и снижает доверие к календарю. Изменение должно заменить визуальный символ, но не менять расчёт статуса, тексты, навигацию, выбор даты, аналитику, загрузку данных или фазу луны.

## 2. Источник истины в Figma

Файл: `Asteria`, file key `iRwq5h8Hi7qqhuFLJ2iEtg`.

Мастер-компонент: `Icon status`, node `4385:9294`.

Варианты:

| Бизнес-статус | Figma variant | Node | Файл-источник | SHA-256 |
|---|---|---|---|---|
| Благоприятный | `Favourable` | `4555:68334` | `assets/2026-08-24-day-status-stars/day_status_favorable_star.png` | `95a0ad55c037526d0b6fde62a909bfdcb75070851ef8b6670846ae7e706bc2d5` |
| Нейтральный | `Neutral` | `4555:68333` | `assets/2026-08-24-day-status-stars/day_status_neutral_star.png` | `ff4d4499936576017d16762f6d35dc5df95f198cd3c542d5994e305ef4ab53a2` |
| Неблагоприятный | `Unfavourable` | `4385:9291` | `assets/2026-08-24-day-status-stars/day_status_unfavorable_star.png` | `0e8ed05b7d00cbb5858b857e21b4e509d915ce1b4d254308e4b038e04a1e8040` |

Каждый файл получен из Figma Export Preview соответствующего варианта, а не сгенерирован и не перерисован. У preview-файлов был непрозрачный фон `#F2F2F2` и checkerboard-подложка preview; они удалены border-connected alpha matte без изменения самой звезды, чтобы production-иконки совпадали с макетом без квадратной подложки. Формат — прозрачный RGBA PNG, 582×582 px. В мастер-компоненте иконка используется в логическом размере 14×14 px.

В production ассеты будут лежать по адресам:

- `assets/icons/day_status_favorable_star.png`;
- `assets/icons/day_status_neutral_star.png`;
- `assets/icons/day_status_unfavorable_star.png`.

## 3. Полная карта затронутых интерфейсов

### 3.1. Лунный календарь: сетка месяца

Файл: `moon_calendar_widget.dart`.

Заменяется иконка статуса под числом дня во всех calendar builders:

- обычный день;
- сегодняшний день;
- выбранный день;
- день с маркером основной фазы луны.

Размер остаётся 14×14 logical px. Маркер фазы луны, стили selected/today, opacity соседних месяцев и обработка нажатия не меняются.

Если для даты нет данных календаря, иконка по-прежнему не показывается. Отсутствие данных нельзя визуально превращать в нейтральный прогноз.

### 3.2. Лунный календарь: легенда

Файл: `calendar_statuses_widget.dart`.

Три старых смайла заменяются на три соответствующие звезды. Размер остаётся 25×25 logical px. Порядок, локализованные подписи и layout легенды сохраняются.

### 3.3. Блок «Фаза луны»: лента дат

Файл: `moon_phase_widget.dart`.

В семидневной ленте над датой/днём недели отображается новая звезда соответствующего статуса. Размер остаётся 14×14 logical px. Выбор даты, горизонтальная прокрутка, prefetch соседних фаз, изображение луны и маркер основной фазы не меняются.

### 3.4. Блок «Фаза луны»: статусный бейдж

Файл: `moon_phase_widget.dart`.

В бейдже «Благоприятный / Нейтральный / Неблагоприятный день» старый смайл заменяется соответствующей звездой. Размер остаётся 25×25 logical px. Цвет, текст, форма и layout бейджа сохраняются.

### 3.5. Что проверено и не требует замены

- `AdviceWidget` и `MoonDesignTokens` используют `DayStatus` для текста, цвета и glow, но не показывают старые status-иконки.
- Остальные звёзды в приложении относятся к валюте, подписке, навигации или декору и не являются статусом дня.
- Других production-ссылок на `good_day_icon.png`, `neutral_day_icon.png`, `bad_day_icon.png` не найдено.

## 4. Бизнес-правила, которые остаются неизменными

Единая классификация числового значения:

- значение `> 0` → `DayStatus.favorable`;
- значение `== 0` → `DayStatus.neutral`;
- значение `< 0` → `DayStatus.unfavorable`.

Источник значения:

- без выбранной сферы — `content.categoryStatus`;
- при выбранной сфере — status соответствующей сферы (`beauty`, `gardening`, `health`, `workAndRest`, `relationships`);
- блок «Фаза луны» использует агрегированный `categoryStatus`.

Семантика отсутствующих данных сохраняется:

- ячейка месяца без данных — без иконки;
- выбранный день без данных и Moon Phase fallback — нейтральный статус, как сейчас.

## 5. Архитектурное решение

### 5.1. Один тип статуса

`DayStatus` выносится из `moon_screen_state.dart` в самостоятельную presentation-модель `lib/features/home/presentation/models/day_status.dart`.

Модель получает единый factory/mapper для классификации знакового числового значения. Это удаляет дублирующие `> 0 / < 0 / else` ветки из `MoonScreenCubit` и `MoonPhaseWidget`, но не смешивает с классификацией отсутствие самой calendar-записи: вызывающий код продолжает решать, показывать ли статус вообще.

Приватный `_MoonDayStatus` и его presentation extension удаляются. `MoonPhaseWidget` использует общий `DayStatus`.

### 5.2. Один каталог ассетов

Создаётся `lib/features/home/presentation/models/day_status_assets.dart` с исчерпывающим mapping `DayStatus → asset path`. В production-коде не должно остаться локальных switch-методов и строковых путей к status-иконкам.

### 5.3. Один renderer

Создаётся `lib/features/home/presentation/widgets/day_status_icon.dart` — общий виджет со следующей ответственностью:

- принимает обязательные `DayStatus status` и `double size`;
- выбирает asset только через центральный mapping;
- использует `BoxFit.contain` и одинаковые правила качества рендера;
- задаёт decode/cache size с учётом device pixel ratio, чтобы 582×582 source не декодировался в полном размере для каждой 14×14 иконки;
- принимает необязательный semantic label либо исключается из semantics, когда рядом уже есть видимый текст статуса;
- не содержит бизнес-классификацию, локализацию или логику выбора даты.

### 5.4. Accessibility

В легенде и статусном бейдже иконка исключается из semantics, потому что статус уже озвучивается соседним текстом.

В интерактивных ячейках календаря и ленте фаз статус добавляется в semantic label дня, чтобы цвет/форма не были единственным способом передачи информации. Дублирование текста screen reader'ом не допускается.

### 5.5. Удаление legacy

После миграции всех call sites удаляются:

- `assets/icons/good_day_icon.png`;
- `assets/icons/neutral_day_icon.png`;
- `assets/icons/bad_day_icon.png`;
- `_MoonDayStatus` и локальные icon-path switch'и.

Это обязательная часть изменения: старый и новый визуальный язык не должны сосуществовать в кодовой базе без причины.

## 6. Обработка ошибок и производительность

- Ошибка отсутствующего asset должна проявляться в тестах; runtime fallback на старый смайл не добавляется.
- Три изображения переиспользуются через Flutter image cache; размер декодирования ограничивается фактическим logical size × DPR.
- Новые asset paths уже покрываются существующей регистрацией `assets/icons/` в `pubspec.yaml`; отдельная ручная регистрация каждого файла не нужна.
- Никаких сетевых запросов, feature flags, localStorage или параллельной legacy-ветки для иконок не вводится.

## 7. Тестовая стратегия

Разработка выполняется через TDD.

### Unit tests

- `DayStatus` правильно классифицирует положительное, нулевое и отрицательное значения;
- каждый статус имеет ровно один новый asset path;
- старые asset paths не возвращаются ни для одного статуса.

### Widget tests

- `DayStatusIcon` отображает все три варианта, соблюдает 14×14 и 25×25, корректно настраивает semantics и decode size;
- легенда содержит три новые звезды с правильным mapping и текстами;
- сетка месяца отображает правильные звёзды для обычного, today и selected состояний;
- день без данных не получает нейтральную иконку автоматически;
- маркер основной фазы остаётся видимым одновременно со status-иконкой;
- Moon Phase strip отображает все три статуса;
- Moon Phase badge использует тот же mapping;
- fallback при отсутствующих данных остаётся нейтральным там, где это текущее бизнес-правило.

### Regression and integration

- обновляется `integration_test/lunar_calendar_distribution_test.dart`;
- production Dart-код и тестовые ожидания не содержат старых asset paths;
- каждый PNG декодируется без ошибки;
- выполняются targeted tests, затем `flutter analyze` и полный `flutter test`;
- integration test запускается отдельно и честно отмечается как заблокированный, если для него нет требуемого runtime/backend окружения.

### Visual QA

На реальном собранном приложении проверяются четыре поверхности из раздела 3 в состояниях favorable/neutral/unfavorable, selected/today, с/без primary phase marker и при разных DPR. Figma node `4385:9294` используется как визуальный эталон.

## 8. Acceptance criteria

1. Во всех четырёх status-icon поверхностях используются только новые звёзды из Figma.
2. Цвет и выражение лица однозначно соответствуют бизнес-статусу.
3. Классификация статуса и missing-data semantics не изменились.
4. Один `DayStatus`, один asset mapping и один renderer используются всеми call sites.
5. Legacy enum/mapping/assets удалены, старые пути отсутствуют в production и тестах.
6. Сетка календаря, легенда, Moon Phase strip и badge проходят widget/regression tests.
7. Статус доступен screen reader без дублирования соседнего текста.
8. `flutter analyze` и `flutter test` проходят; граница integration/UI проверки указана отдельно.

## 9. Риски и ограничения

- Figma-файл доступен только на просмотр. Экспорт через обычную кнопку не возвращал browser download event, поэтому PNG сохранены из DOM-backed Export Preview каждого master-variant. Preview-фон `#F2F2F2` и checkerboard-подложка были удалены после simulator QA, потому что иначе звёзды отображались квадратными подложками, в отличие от дизайна.
- Figma MCP не может читать этот файл без edit-доступа. Это не влияет на полученные через авторизованный браузер ассеты, но исключает автоматическое повторное скачивание через MCP до изменения прав.
- Изменение порядка или формы `DayStatus` не должно затронуть persistence: аудит не нашёл использования `DayStatus.index`/`values` или сериализации enum. Это повторно проверяется перед реализацией.

## 10. Использованные официальные рекомендации

- Flutter assets and resolution-aware images: https://docs.flutter.dev/ui/assets/assets-and-images
- `Image.asset`: https://api.flutter.dev/flutter/widgets/Image/Image.asset.html
- Flutter `Semantics`: https://api.flutter.dev/flutter/widgets/Semantics-class.html
- Flutter accessibility testing: https://docs.flutter.dev/ui/accessibility/accessibility-testing
- Flutter testing overview: https://docs.flutter.dev/testing/overview
- WCAG 2.2 Use of Color: https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html
