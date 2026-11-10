# Asteria App — кратко о проекте

**Стек:** Flutter, Dart 3.8+.

**Суть:** мобильное приложение Asteria (астрология, таро, контент, покупки и др.). Пакет: `asteria_app`.

## Структура `lib/`

- **`app/`** — точка входа (`app.dart`), глобальные провайдеры, модели и базовые репозитории.
- **`core/`** — инфраструктура: DI (`core/di/di.dart`, GetIt), роутинг (GoRouter), локализация, сервисы (Firebase, API, Hive и т.д.), UI kit.
- **`features/`** — фичи по папкам; у части есть полная цепочка `data` / `domain` / `presentation`, у части — в основном `presentation`.

Подробные соглашения по папкам, BLoC/Cubit/Provider и регистрации в DI см. в `.cursor/rules/flutter-development-general.mdc` (если используете Cursor).

## Состояние и DI

- **BLoC** — сложные фичи; **Cubit** — проще; **Provider (ChangeNotifier)** — глобальное и некоторое локальное состояние.
- Зависимости регистрируются в **`DiContainer.initialize()`** в `core/di/di.dart`.

## Данные

- **Firestore**, **Hive** (локально), вызовы через **`FirebaseFunctionsApi`**, отдельные HTTP/API-сервисы в `core/services/api/`.

## Android-платежи

- В Google Play-сборке страна берётся из BillingConfig: `RU` использует Arc Pay, остальные страны и ошибка определения — Google Play Billing.
- Для альтернативных Android-магазинов сборка с `--dart-define=ASTERIA_DISTRIBUTION_CHANNEL=ru` всегда использует Arc Pay.
- Временная диагностика региона включается только через `--dart-define=ASTERIA_PAYMENT_DIAGNOSTICS=true`.

## Маршруты

- GoRouter: схема и маршруты в **`core/routing/`** (`routing_scheme.dart`, папка `routes/`).

## Локализация

- `core/localization/`, ARB для русского и сгенерированные файлы.

## Что почитать в коде первым делом

1. `lib/app/app.dart` — провайдеры, тема, роутер.  
2. `lib/core/di/di.dart` — как собраны зависимости.  
3. Нужная фича в `lib/features/<имя>/`.
