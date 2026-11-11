# Asteria App Codex Instructions

Эти правила применяются ко всем файлам внутри `asteria-app/` и дополняют глобальный `.codex/AGENTS.md`.

## Сохранение работоспособности

Asteria — готовое работающее приложение. При каждой правке сохраняй поведение за пределами явно запрошенного изменения и совместимость с уже сохранёнными данными пользователей.

- При каждом замечании к интерфейсу проверь все экраны с таким компонентом, включая его локальные копии. Исправь причину во всех затронутых местах и проверь остальные варианты элемента.
- До правки проверь, как сейчас работает затронутый сценарий. Если компонент общий, найди экраны и действия, которые от него зависят.
- Делай минимальное изменение по задаче. Сохраняй возможность откатить именно свою правку, не затрагивая работу пользователя.
- После правки повтори тот же сценарий и проверь связанные с ним действия. Для изменений интерфейса пройди их на виртуальном iPhone, для изменений логики выполни подходящие тесты из раздела Checks.
- Если обнаружилась новая поломка, исправь её или откати свою правку и повтори проверку. Явно сообщай, что проверено и что осталось непроверенным.

## Git и восстановление

- Исходники мобильного приложения веди в этом проекте. Репозиторий для push — личный GitHub `avvolkova13/asteria-app`.
- Перед существенной правкой проверь ветку, remote и рабочее дерево. Зафиксируй согласованную исходную версию, чтобы можно было вернуться к ней. Сохраняй независимые изменения отдельными осмысленными локальными коммитами.
- После проверки законченной задачи проверь staged diff, сделай коммит, отправь текущую рабочую ветку в origin и сверь идентификатор локального и удалённого коммитов. В отчёте укажи ветку, короткий хеш и результат проверок. Учитывай явные указания по конкретной задаче.
- Для отката опубликованного изменения используй отдельный revert-коммит. Сохраняй текущие незакоммиченные правки перед восстановлением. Не переписывай общую историю и не используй force push.
- Репозиторий публичный. Проверяй новые файлы перед добавлением. Локальные секреты, конфиги сервисов с ключами, ключи подписи и скриншоты с персональными данными храни вне Git. Включай исходники, ресурсы и lock-файлы зависимостей в точки восстановления.

## Scope

`asteria-app/` - Flutter/Dart 3.8+ mobile app с пакетом `asteria_app`.

Перед изменениями прочитай:

1. `PROJECT.md` - краткая карта приложения.
2. `pubspec.yaml` - зависимости, assets, fonts, localization config.
3. `analysis_options.yaml` - lint-правила.
4. Релевантную feature-папку в `lib/features/<feature>/` и соседние похожие реализации.

## Stack

- Flutter, Dart 3.8+, null safety.
- State management: `flutter_bloc` для BLoC/Cubit, `provider`/`ChangeNotifier` для глобального и простого локального состояния.
- DI: `get_it`, контейнер в `lib/core/di/di.dart`.
- Routing: `go_router`, маршруты в `lib/core/routing/`.
- Backend/data: Firebase Core, Firestore, Firebase Functions, Hive, Dio.
- Analytics/payments: AppsFlyer, ATT permission, in-app purchases, StoreKit для iOS, legacy payment path для Android.

## Structure

- `lib/app/` - app entry, глобальные providers, app-level data/models/repositories.
- `lib/core/` - инфраструктура: DI, routing, localization, analytics, payments, services, UI kit, utils.
- `lib/features/` - фичи приложения. Часть фич имеет цепочку `data` / `domain` / `presentation`, часть содержит только presentation/widgets.
- `test/` - unit/widget tests рядом с проверяемым поведением по смыслу.

## Implementation Rules

- Следуй существующей архитектуре конкретной feature-папки; не вводи новый слой, если рядом его нет и задача этого не требует.
- Для новых сервисов, repositories, Cubit/BLoC/Provider добавляй регистрацию в `lib/core/di/di.dart`, если объект должен жить через DI.
- Новые маршруты добавляй в существующую структуру `lib/core/routing/` и используй уже принятые route naming patterns.
- Предпочитай `StatelessWidget`; используй `StatefulWidget` только для lifecycle/local state.
- Используй `const` constructors, single quotes и trailing commas, где это уместно.
- Избегай `!` и `dynamic`, если безопасность не очевидна из локального контекста.
- Ошибки async/API/Firebase/Hive обрабатывай явно и сохраняй loading/error/empty states, если flow их подразумевает.

## UI

Перед изменением iOS-интерфейса прочитай [руководство Asteria для iOS](docs/ios-interface-guidelines.md). Для навигации, жестов и доступности используй проектный навык `mobile-ios-design`, для адаптивной вёрстки — `flutter-build-responsive-layout`, для проверки поведения виджета — `flutter-add-widget-test`. Выбирай навыки по задаче из `.agents/skills/` и проверяй затронутый сценарий по руководству.

- Используй `lib/core/ui_kit/`, `AppColors`, app theme и существующие shared widgets.
- Не добавляй случайные hardcoded HEX colors, если есть theme tokens или похожий локальный паттерн.
- Проверяй layout на overflow, длинный русский текст, компактные экраны и disabled/loading/error states.
- Для assets используй существующую систему `assets/` и регистрацию в `pubspec.yaml`.

## Localization and Assets

- Основная локализация находится в `lib/core/localization/l10n/`.
- Generated localization files в `lib/core/localization/generated/` не правь вручную без необходимости; при l10n-изменениях учитывай генерацию из `README.md`.
- Новые assets добавляй в `pubspec.yaml` и проверяй, что путь соответствует существующей структуре.

## Analytics and Privacy

- Для analytics-задач сначала прочитай `docs/analytics-events-plan.md` и `lib/core/analytics/`.
- Не отправляй PII в аналитику: телефон, имя, точную дату/место рождения, текст сна, текст сообщения Анакры, partner names, payment payload.
- Для продуктовой аналитики предпочитай централизованные `ProductAnalyticsService`, `AnalyticsFacade`, `AnalyticsEvents`, `EventParams` вместо ad hoc event strings в UI.

## Checks

Запускай проверки из `asteria-app/` и выбирай минимально достаточный набор:

- `flutter analyze` - после Dart/Flutter изменений.
- `flutter test` - после изменений логики или tests.
- Targeted tests вроде `flutter test test/core/utils/phone_formatter_test.dart` - для узких изменений.
- Для dependency/l10n задач учитывай команды из `README.md`: `dart pub get`, `dart run intl_utils:generate`.

Если проверку нельзя запустить, явно укажи причину в ответе.

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **asteria-app** (10796 symbols, 21561 relationships, 244 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? `npx gitnexus analyze` (npm 11 crash → `npm i -g gitnexus`; #1939).

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows. For regression review, compare against the default branch: `detect_changes({scope: "compare", base_ref: "main"})`.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `query({search_query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `context({name: "symbolName"})`.
- For security review, `explain({target: "fileOrSymbol"})` lists taint findings (source→sink flows; needs `analyze --pdg`).

## Never Do

- NEVER edit a function, class, or method without first running `impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit changes without running `detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/asteria-app/context` | Codebase overview, check index freshness |
| `gitnexus://repo/asteria-app/clusters` | All functional areas |
| `gitnexus://repo/asteria-app/processes` | All execution flows |
| `gitnexus://repo/asteria-app/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
