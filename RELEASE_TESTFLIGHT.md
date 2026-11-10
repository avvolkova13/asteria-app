# Подготовка к TestFlight — что осталось сделать руками

Что я уже сделал автоматически (видно в `git status`):

- ✅ `ios/Runner.xcodeproj/project.pbxproj`
  - Bundle ID `com.example.asteriaApp` → `com.toolsafesolutions.asteria` (включая RunnerTests)
  - Team ID `R636RPLN72` → `R93Z9MG29X`
  - `IPHONEOS_DEPLOYMENT_TARGET` 13.0 → 15.0 (синхронно с Podfile)
  - Добавлены `CODE_SIGN_STYLE = Automatic`, `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements`, `MARKETING_VERSION = $(FLUTTER_BUILD_NAME)` во все три Runner-конфигурации (Debug, Release, Profile)
- ✅ `ios/Runner/Info.plist` — добавлен `NSLocationWhenInUseUsageDescription`
- ✅ `ios/Runner/Runner.entitlements` — создан с `aps-environment=development` и пустым `associated-domains`
- ✅ `ios/Runner/PrivacyInfo.xcprivacy` — создан с минимальным манифестом под Firebase + AppsFlyer
- ✅ `pubspec.yaml` — версия оставлена `1.0.5+17` (история билдов сохраняется; build number поднимай на каждый загруженный в TestFlight билд: `1.0.5+18`, `1.0.5+19`, ...)

---

## Шаги, которые делаешь сам

### Шаг A. Подготовка окружения (один раз)

1. Xcode установлен и открыт хотя бы раз: `sudo xcodebuild -license accept`
2. **Xcode → Settings → Accounts**: добавь Apple ID, привязанный к команде **Tool Safe Solutions Limited**. Если у тебя самого нет инвайта в Apple Developer Team `R93Z9MG29X` — попроси менеджера добавить тебя ролью `App Manager` или `Developer`.
3. Проверь: `flutter doctor -v`. Для iOS нужны зелёные:
   - `Flutter`
   - `Xcode - develop for iOS`
   - `CocoaPods`
   - `Android toolchain` с крестиком — ОК, нам не нужен

### Шаг B. Firebase — перегенерация iOS-app под новый Bundle ID

1. https://console.firebase.google.com → проект `asteria-app-58fd9`
2. **Project Settings** (шестерёнка) → раздел **Your apps** → **Add app** → **iOS** (значок Apple)
3. Заполни:
   - iOS bundle ID: `com.toolsafesolutions.asteria`
   - App nickname: `Asteria iOS`
   - App Store ID: `6766823016` (тот самый Apple app ID из задачи)
4. Скачай `GoogleService-Info.plist`
5. **Замени** файл `ios/Runner/GoogleService-Info.plist` (положи на то же место, имя то же)
6. Открой свежий plist и убедись, что внутри:
   ```xml
   <key>BUNDLE_ID</key>
   <string>com.toolsafesolutions.asteria</string>
   ```
7. Старое iOS-приложение (`com.example.asteriaApp`) в Firebase Console **не удаляй** — оставь, пусть висит.

### Шаг C. Обновить `.env` (некоммитимый файл в корне репо)

Открой `.env` и поменяй:

```env
# Bundle ID
FIREBASE_IOS_BUNDLE_ID=com.toolsafesolutions.asteria

# Эти значения возьми из свежескачанного GoogleService-Info.plist:
FIREBASE_APP_ID_IOS=<значение из <key>GOOGLE_APP_ID</key>>
FIREBASE_API_KEY_IOS=<значение из <key>API_KEY</key>>

# Прод-бекенд вместо localhost
ASTERIA_BACKEND_URL=<твой prod URL>
```

### Шаг D. Apple Developer Portal — зарегистрировать App ID

1. https://developer.apple.com/account/resources/identifiers/list (войти под аккаунтом Tool Safe Solutions Limited)
2. Проверь — может быть `com.toolsafesolutions.asteria` уже есть (создан вместе с App Store Connect record). Если есть → клик → проверь что **Push Notifications** и **Associated Domains** включены в списке Capabilities. Если выключены → включи → Save.
3. Если App ID отсутствует:
   - **+ Identifiers** → App IDs → App
   - Description: `Asteria`
   - Bundle ID (Explicit): `com.toolsafesolutions.asteria`
   - В списке Capabilities отметь **Push Notifications** и **Associated Domains**
   - Continue → Register

### Шаг E. Xcode — подвязать новые файлы к проекту (минута)

`Runner.entitlements` уже подключён через build settings — Xcode при открытии его увидит. Но `PrivacyInfo.xcprivacy` надо добавить к target вручную:

1. Открой `ios/Runner.xcworkspace` в Xcode (не `.xcodeproj`, а именно workspace!)
2. В левой панели Project Navigator выбери папку **Runner** (вторая сверху, не верхнюю с тем же именем)
3. Правый клик → **Add Files to "Runner"...**
4. Найди и выбери `ios/Runner/PrivacyInfo.xcprivacy`
5. Внизу диалога: галка **Add to targets: Runner** должна стоять (другие — нет)
6. Add

Проверка: выбери `PrivacyInfo.xcprivacy` в навигаторе, справа в инспекторе раздел **Target Membership** — должна быть галка у `Runner`. Без этой галки файл не попадёт в бинарник и Apple пришлёт ITMS-91053.

### Шаг F. Xcode — Signing & Capabilities (проверка)

1. В Xcode выбери таргет **Runner** (главное окно настроек проекта) → таб **Signing & Capabilities**
2. Сверху три суб-таба: All, Debug, Release. Смотри **All**.
3. Должно быть:
   - **Automatically manage signing** ✓ (включено)
   - **Team**: Tool Safe Solutions Limited (R93Z9MG29X)
   - **Bundle Identifier**: `com.toolsafesolutions.asteria`
   - **Provisioning Profile**: Xcode Managed Profile (если красный значок — нажми «Try Again» или подожди, Xcode выпустит профиль автоматически)
4. Ниже список capabilities. Если **Push Notifications** и **Associated Domains** не видны (а они должны быть видны — мы прописали их в Runner.entitlements):
   - **+ Capability** в левом верхнем углу → найди и добавь Push Notifications → потом Associated Domains
   - Xcode объединит с существующим entitlements-файлом.
5. **Associated Domains** оставь с пустым списком — `applinks:` дойдём позже, когда менеджер пришлёт OneLink-домен.

Если в этой панели остаются красные ошибки (например про missing entitlement) — обычно лечится:
- Нажми «Try Again» возле ошибки
- Или зайди в Developer Portal (Шаг D) и убедись что capabilities в App ID включены

### Шаг G. Локальный smoke-test перед сборкой

Из корня репо:

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter analyze
```

`flutter analyze` не должен показать фатальных ошибок. Warnings — ок.

Дальше — smoke-test, в одном из двух вариантов в зависимости от того, есть ли физический iPhone:

**Вариант 1: только симулятор (айфона нет)**

```bash
flutter run            # Debug-режим, работает в симуляторе
```

`flutter run --release` **на симуляторе не запустится** — это ограничение Flutter
(Release использует AOT-компиляцию под ARM64-iPhone, симулятор её не понимает).
Это не баг, так задумано. Debug-сборки достаточно чтобы проверить:
приложение запускается, Firebase инициализируется без ошибок в логах
(`Firebase Core initialized`), сплэш не падает.

**Вариант 2: физический iPhone подключён по USB**

```bash
flutter run --release   # полноценный Release с реальной подписью
```

Если приложение запустилось и не падает на сплэш-скрине — Firebase и AppsFlyer
корректно подцепились к новому Bundle ID.

**Если iPhone нет под рукой** — smoke-test можно пропустить и идти сразу на Шаг H
(`flutter build ipa --release`). Xcode при Archive всё равно проведёт полную
валидацию подписи и капабилити.

### Шаг H. Сборка release-архива

```bash
flutter build ipa --release
```

Команда соберёт `build/ios/archive/Runner.xcarchive` и `build/ios/ipa/asteria_app.ipa`.

Если хочешь через Xcode UI:

1. Открой `ios/Runner.xcworkspace`
2. Сверху рядом с кнопкой Play выбери destination **Any iOS Device (arm64)**
3. **Product → Archive**
4. По завершении откроется **Organizer**

### Шаг I. Загрузка в App Store Connect

Из Xcode Organizer (если собирал через Archive в Xcode):

1. Выбрать только что собранный архив
2. **Distribute App** → **App Store Connect** → **Upload**
3. **Automatically manage signing** → Next
4. Дождаться валидации Apple (1-3 мин)
5. **Upload** → ждать загрузки

Альтернативно, если собирал через `flutter build ipa`:

- Загрузить файл `build/ios/ipa/asteria_app.ipa` через **Transporter.app** (бесплатно в App Store на Mac) — открой Transporter, перетащи `.ipa`, **Deliver**.

### Шаг J. App Store Connect → TestFlight

1. https://appstoreconnect.apple.com → **Apps** → **Asteria**
2. Перейди в таб **TestFlight**
3. Подожди 10–30 минут — статус билда сменится с `Processing` на готовый
4. Если появится `Missing Compliance` — клик на билд → **Export Compliance**: «Uses Encryption? → Yes → Standard encryption (HTTPS)? → Yes → Exempt». Сохрани.
5. **Internal Testing** → **+** возле «Groups» → создать группу `Internal QA` → добавить туда себя по Apple ID
6. После добавления группы выбери билд → пометь к этой группе доступным
7. На iPhone установи приложение **TestFlight** из App Store, залогинься тем же Apple ID — приложение Asteria появится через 5–10 минут

### Шаг K. На случай если Apple пришлёт письмо

Сразу после Processing на email может прилететь автоматическое письмо с кодом
`ITMS-XXXXX`. Что часто:

- **ITMS-90683** — не хватает Usage Description в Info.plist. Добавь нужный ключ → пересобери с увеличенным build number (`1.0.0+2`) → залей заново.
- **ITMS-91053** — privacy manifest не покрывает какой-то API. В письме указано, какой API и какой `reason` добавить — расширь `PrivacyInfo.xcprivacy` → bump build number → пересобери.
- **ITMS-90078** — provisioning profile не подписан правильно. Чаще всего лечится `Try Again` в Xcode и повторной сборкой.

---

## Финальный чек-лист перед `flutter build ipa --release`

- [ ] Шаг A: Xcode залогинен под Tool Safe Solutions Limited
- [ ] Шаг B: новый `GoogleService-Info.plist` лежит в `ios/Runner/`, внутри Bundle ID = `com.toolsafesolutions.asteria`
- [ ] Шаг C: `.env` обновлён (Bundle ID, Firebase iOS keys, prod backend URL)
- [ ] Шаг D: App ID `com.toolsafesolutions.asteria` зарегистрирован в Developer Portal, Push + Associated Domains включены
- [ ] Шаг E: `PrivacyInfo.xcprivacy` добавлен к target Runner в Xcode (галка стоит)
- [ ] Шаг F: в Xcode Signing & Capabilities — без красных ошибок, Team = R93Z9MG29X, Bundle ID правильный, Provisioning Profile подгрузился
- [ ] Шаг G: `flutter analyze` без фатальных ошибок, `pod install` прошёл
- [ ] (опционально) Прогнал `flutter run --release` на физическом iPhone — приложение запускается

---

## Что отложили — НЕ делаем в этом билде

- **firebase_messaging и реальная отправка пушей** — capability Push Notifications включена, но в Dart-коде ничего не подключаем. APNs key в Developer Portal сделаем когда дойдём до реальных пушей.
- **Геолокация устройства (CoreLocation, geolocator)** — у нас только Yandex Geo API по введённому адресу. `NSLocationWhenInUseUsageDescription` добавлен как задел.
- **applinks: AppsFlyer OneLink** — capability Associated Domains подключена, массив пустой. Заполним когда менеджер пришлёт домен (Xcode → Signing & Capabilities → Associated Domains → + → `applinks:<домен>`).
- **Flavors / разделение env по конфигурациям** — пока меняем `.env` руками. Заведём `--dart-define` или flavors когда будет 2–3 билда в неделю.
- **Fastlane / CI** — после 2–3 успешных ручных upload'ов заведём `fastlane/Fastfile` с лейном `beta`.
