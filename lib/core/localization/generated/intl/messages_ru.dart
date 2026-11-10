// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(title) => "${title}. Закрыто";

  static String m1(count, total) => "Осталось ${count} из ${total}";

  static String m2(category) => "${category}. Только по подписке";

  static String m3(text) => "Аффирмация: ${text}";

  static String m4(free, total, paid) => "${free}/${total} + ${paid} куплено";

  static String m5(count) =>
      "${Intl.plural(count, one: 'Осталась ${count} попытка', few: 'Осталось ${count} попытки', many: 'Осталось ${count} попыток', other: 'Осталось ${count} попытки')}";

  static String m6(balance) => "Баланс: ${balance} звезд";

  static String m7(price) => "Купить за ${price}";

  static String m8(price) => "Купить натальную карту за ${price} звёздочётов";

  static String m9(title, price) => "Купить ${title} за ${price} звёзд";

  static String m10(price) =>
      "Купить персональный гороскоп на год за ${price} звёздочётов";

  static String m11(coins) => "Пакет ${coins} звёздочётов";

  static String m12(rune) => "Руна дня: ${rune}";

  static String m13(card) => "Карта Таро дня: ${card}";

  static String m14(number) => "Карта ${number}";

  static String m15(number, title) => "Карта ${number}: ${title}";

  static String m16(details) => "Ошибка: ${details}";

  static String m17(count) =>
      "Бесплатные запросы обновятся через ${Intl.plural(count, one: '${count} день', few: '${count} дня', many: '${count} дней', other: '${count} дня')}.";

  static String m18(count) =>
      "Бесплатные запросы обновятся через ${Intl.plural(count, one: '${count} день', few: '${count} дня', many: '${count} дней', other: '${count} дня')}.";

  static String m19(price) => "${price} в месяц";

  static String m20(price) => "${price} в неделю";

  static String m21(price) => "${price} в год";

  static String m22(price) => "${price}. Автопродление, отмена в любой момент.";

  static String m23(price) =>
      "7 дней бесплатно, затем ${price}. Автопродление, отмена в любой момент.";

  static String m24(number, position) => "Карта №${number} — ${position}";

  static String m25(count) =>
      "Лимит обновится через ${Intl.plural(count, one: '${count} день', few: '${count} дня', many: '${count} дней', other: '${count} дня')}.";

  static String m26(title) => "Фон дня: ${title}";

  static String m27(time) => "Наступает в ${time} по вашему времени";

  static String m28(sphere, status) => "Сфера «${sphere}»: ${status}";

  static String m29(number) => "Акцент на ${number} доме";

  static String m30(price) => "Твоя натальная карта\nза ${price} звёздочётов";

  static String m31(number) => "Сильный ${number} дом";

  static String m32(number) => "Слабый ${number} дом";

  static String m33(title) => "Открыть статью: ${title}";

  static String m34(count) =>
      "${Intl.plural(count, zero: 'Купленных запросов нет', one: '${count} купленный запрос', few: '${count} купленных запроса', many: '${count} купленных запросов', other: '${count} купленного запроса')}";

  static String m35(coins, balance) =>
      "Начислено монет: ${coins}. Баланс: ${balance}";

  static String m36(coins) => "Начислено монет: ${coins}. Баланс обновлён.";

  static String m37(countryCode, provider) =>
      "Диагностика оплаты\nРегион магазина: ${countryCode}\nВыбранный провайдер: ${provider}";

  static String m38(price) => "Открой прогноз\nза ${price} звёздочётов";

  static String m39(name) => "Привет, ${name}!";

  static String m40(price) => "Слабые места за ${price}";

  static String m41(title, price) => "Купить ${title} за ${price} звёзд";

  static String m42(title, price) => "Купить ${title} за ${price}";

  static String m43(count) =>
      "Покупка ${Intl.plural(count, one: '${count} запроса', few: '${count} запросов', many: '${count} запросов', other: '${count} запроса')}";

  static String m44(price) => "1 вопрос = ${price}";

  static String m45(count) =>
      "Через ${Intl.plural(count, one: '${count} день', few: '${count} дня', many: '${count} дней', other: '${count} дня')} лимит обновится.";

  static String m46(count) =>
      "${Intl.plural(count, one: '${count} запрос', few: '${count} запроса', many: '${count} запросов', other: '${count} запроса')}";

  static String m47(count, price) =>
      "${Intl.plural(count, one: '${count} запрос за ${price} звёзд', few: '${count} запроса за ${price} звёзд', many: '${count} запросов за ${price} звёзд', other: '${count} запроса за ${price} звёзд')}";

  static String m48(count) =>
      "${Intl.plural(count, zero: 'Запросов не осталось', one: 'Остался ${count} запрос', few: 'Осталось ${count} запроса', many: 'Осталось ${count} запросов', other: 'Осталось ${count} запроса')}";

  static String m49(count, total) => "${count}/${total} запросов осталось";

  static String m50(count) =>
      "${Intl.plural(count, zero: 'Бесплатных запросов на эту неделю не осталось', one: 'Остался ${count} бесплатный запрос на эту неделю', few: 'Осталось ${count} бесплатных запроса на эту неделю', many: 'Осталось ${count} бесплатных запросов на эту неделю', other: 'Осталось ${count} бесплатного запроса на эту неделю')}";

  static String m51(count, total) => "Осталось запросов: ${count} из ${total}";

  static String m52(link) =>
      "Открой для себя Asteria — гороскопы, Таро и лунный календарь: ${link}";

  static String m53(title) => "Руна ${title} закрыта";

  static String m54(title) => "Открыть значение руны будущего ${title}";

  static String m55(title) => "Открыть руну ${title}";

  static String m56(title) => "Открыть значение руны прошлого ${title}";

  static String m57(title) => "Открыть значение руны настоящего ${title}";

  static String m58(count) => "${count} шт.";

  static String m59(price) => "цена за 1 = ${price}";

  static String m60(date) => "Следующее списание\nбудет произведено\n${date}";

  static String m61(count) => "Восстановлено покупок: ${count}";

  static String m62(title) => "Карта ${title} закрыта";

  static String m63(title) => "Открыть карту ${title}";

  static String m64(position) => "Открыть карту ${position} из 3";

  static String m65(position, card) => "Карта ${position} из 3: ${card}";

  static String m66(price) =>
      "Твой персональный гороскоп\nна год за ${price} звёздочётов";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutTitle": MessageLookupByLibrary.simpleMessage("О приложении"),
    "achievementHoroscope": MessageLookupByLibrary.simpleMessage(
      "Открыть гороскоп",
    ),
    "achievementLocked": m0,
    "achievementRemaining": m1,
    "achievementRunes": MessageLookupByLibrary.simpleMessage("Открыть руны"),
    "achievementTarot": MessageLookupByLibrary.simpleMessage(
      "Раскинуть карты Таро",
    ),
    "achievementsTitle": MessageLookupByLibrary.simpleMessage("Мои достижения"),
    "adDecode": MessageLookupByLibrary.simpleMessage("Расшифровать"),
    "adDreamDescription": MessageLookupByLibrary.simpleMessage(
      "Расскажи свой сон —\nона откроет\nего значение.",
    ),
    "adDreamTitle": MessageLookupByLibrary.simpleMessage("Приснился сон?"),
    "adLiviaName": MessageLookupByLibrary.simpleMessage("Ливея"),
    "adLiviaSubtitle": MessageLookupByLibrary.simpleMessage(
      "хранительница снов.",
    ),
    "affirmationCategoryAbundance": MessageLookupByLibrary.simpleMessage(
      "Изобилие",
    ),
    "affirmationCategoryCalm": MessageLookupByLibrary.simpleMessage(
      "Спокойствие",
    ),
    "affirmationCategoryCreativity": MessageLookupByLibrary.simpleMessage(
      "Творчество",
    ),
    "affirmationCategoryLocked": m2,
    "affirmationCategoryLove": MessageLookupByLibrary.simpleMessage("Любовь"),
    "affirmationCategoryLunar": MessageLookupByLibrary.simpleMessage("Лунные"),
    "affirmationCategoryStrength": MessageLookupByLibrary.simpleMessage("Сила"),
    "affirmationLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить аффирмацию. Проверьте интернет.",
    ),
    "affirmationLoading": MessageLookupByLibrary.simpleMessage(
      "Загружаем аффирмацию…",
    ),
    "affirmationLoadingLabel": MessageLookupByLibrary.simpleMessage(
      "Загрузка аффирмации дня",
    ),
    "affirmationOfDay": MessageLookupByLibrary.simpleMessage("Аффирмация дня"),
    "affirmationOpenPlayer": MessageLookupByLibrary.simpleMessage(
      "Открыть аудиоплеер",
    ),
    "affirmationRetryLabel": MessageLookupByLibrary.simpleMessage(
      "Повторить загрузку аффирмации",
    ),
    "affirmationSemantics": m3,
    "affirmationSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Эта аффирмация доступна в рамках подписки. Получите доступ ко всем аффирмациям, включая закрытые категории, а также другим эксклюзивным функциям.",
    ),
    "affirmationSwipeHint": MessageLookupByLibrary.simpleMessage(
      "Смахните влево или вправо, чтобы переключить аффирмацию",
    ),
    "affirmationUnavailableLabel": MessageLookupByLibrary.simpleMessage(
      "Аффирмация дня недоступна",
    ),
    "affirmationsTitle": MessageLookupByLibrary.simpleMessage("Аффирмации"),
    "agreementSummary": MessageLookupByLibrary.simpleMessage(
      "Пользовательское соглашение устанавливает условия использования Asteria и регулирует доступ к цифровому контенту, функциям, подпискам и покупкам.",
    ),
    "agreementText": MessageLookupByLibrary.simpleMessage(
      "Пользовательское соглашение",
    ),
    "allAffirmations": MessageLookupByLibrary.simpleMessage("Все аффирмации"),
    "anakraFreeAndPurchased": m4,
    "anakraGreetingMessage": MessageLookupByLibrary.simpleMessage(
      "Приветствую тебя. Я Анакра — хранительница звёздных знаков и твоего небесного пути. Задай свой вопрос — или выбери, с чего начать.",
    ),
    "anakraGreetingTitle": MessageLookupByLibrary.simpleMessage(
      "Приветствую.\nЯ Анакра —\nхранительница\nзвёзд и твоего\nпути.",
    ),
    "anakraInputHint": MessageLookupByLibrary.simpleMessage(
      "Задай свой вопрос",
    ),
    "anakraName": MessageLookupByLibrary.simpleMessage("Анакра"),
    "anakraQuickCompatibility": MessageLookupByLibrary.simpleMessage(
      "Узнать совместимость",
    ),
    "anakraQuickDrawCard": MessageLookupByLibrary.simpleMessage(
      "Вытянуть карту",
    ),
    "anakraQuickNatalChart": MessageLookupByLibrary.simpleMessage(
      "Покажи мою натальную карту",
    ),
    "anakraQuickPowerDay": MessageLookupByLibrary.simpleMessage(
      "Когда мой следующий день силы?",
    ),
    "anakraReady": MessageLookupByLibrary.simpleMessage(
      "Звёзды готовы ответить.",
    ),
    "anakraRequestsLeftLabel": MessageLookupByLibrary.simpleMessage(
      "Осталось запросов Анакра",
    ),
    "anakraSendMessageLabel": MessageLookupByLibrary.simpleMessage(
      "Отправить сообщение",
    ),
    "anakraServerError": MessageLookupByLibrary.simpleMessage(
      "Сервер не смог ответить. Попробуйте ещё раз.",
    ),
    "anakraTitle": MessageLookupByLibrary.simpleMessage("AI-Астролог Анакра"),
    "anakraTyping": MessageLookupByLibrary.simpleMessage("Анакра печатает…"),
    "anakraWelcomeMessage": MessageLookupByLibrary.simpleMessage(
      "Приветствую тебя. Я Анакра — хранительница звёздных знаков и твоего небесного пути. Задай свой вопрос — или выбери, с чего начать.",
    ),
    "applePurchaseAccount": MessageLookupByLibrary.simpleMessage(
      "Эта покупка Apple связана с другим аккаунтом Asteria. Войдите в него, чтобы пользоваться покупкой.",
    ),
    "applePurchaseActive": MessageLookupByLibrary.simpleMessage(
      "Подписка уже активна. Управлять ей можно в App Store.",
    ),
    "applePurchaseApproval": MessageLookupByLibrary.simpleMessage(
      "Ожидаем одобрения покупки. Позже можно проверить статус здесь.",
    ),
    "applePurchaseCheckStatus": MessageLookupByLibrary.simpleMessage(
      "Проверить статус",
    ),
    "applePurchaseInvalid": MessageLookupByLibrary.simpleMessage(
      "Не удалось подтвердить покупку. Обратитесь в поддержку.",
    ),
    "applePurchaseOffline": MessageLookupByLibrary.simpleMessage(
      "Не удалось проверить статус покупки. Подключитесь к сети и проверьте снова.",
    ),
    "applePurchaseWaiting": MessageLookupByLibrary.simpleMessage(
      "Apple ещё не подтвердил покупку. Проверьте её статус перед повторной оплатой.",
    ),
    "arcPaySubscriptionUnavailable": MessageLookupByLibrary.simpleMessage(
      "Подписка через Arc Pay пока недоступна",
    ),
    "arcPaySubscriptionUnavailableDescription":
        MessageLookupByLibrary.simpleMessage(
          "Покупка звёзд через СБП работает. Подписку мы включим после завершения тестирования сохранённых карт.",
        ),
    "arcSubscriptionCancelError": MessageLookupByLibrary.simpleMessage(
      "Не удалось отменить подписку. Попробуйте позже.",
    ),
    "arcSubscriptionCreateError": MessageLookupByLibrary.simpleMessage(
      "Не удалось создать подписку. Попробуйте позже.",
    ),
    "arcSubscriptionNotFound": MessageLookupByLibrary.simpleMessage(
      "Подписка Arc Pay не найдена.",
    ),
    "arcSubscriptionProductsError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить доступные тарифы Arc Pay.",
    ),
    "arcSubscriptionRetryError": MessageLookupByLibrary.simpleMessage(
      "Не удалось повторить платёж. Попробуйте позже.",
    ),
    "articleNotFound": MessageLookupByLibrary.simpleMessage(
      "Статья не найдена",
    ),
    "articlesReadMore": MessageLookupByLibrary.simpleMessage("Читайте ещё"),
    "articlesScrollLabel": MessageLookupByLibrary.simpleMessage(
      "Прокрутить статьи",
    ),
    "articlesTitle": MessageLookupByLibrary.simpleMessage("Статьи"),
    "asteriaWebsite": MessageLookupByLibrary.simpleMessage("Сайт Asteria"),
    "astrologyLoadingChart": MessageLookupByLibrary.simpleMessage(
      "Собираем карту твоей судьбы…",
    ),
    "astrologyLoadingPersonal": MessageLookupByLibrary.simpleMessage(
      "Готовим твой персональный гороскоп…",
    ),
    "astrologyLoadingStars": MessageLookupByLibrary.simpleMessage(
      "Читаем послания звёзд…",
    ),
    "astrologyLoadingSymbols": MessageLookupByLibrary.simpleMessage(
      "Расшифровываем астрологические символы…",
    ),
    "attemptsLeftCount": m5,
    "authBirthDetailsPrompt": MessageLookupByLibrary.simpleMessage(
      "Укажи дату, время и место рождения — и Вселенная заговорит с тобой.",
    ),
    "authCosmicEssence": MessageLookupByLibrary.simpleMessage(
      "Познай свою космическую суть",
    ),
    "authMoonRhythms": MessageLookupByLibrary.simpleMessage(
      "Настройся на ритмы Луны и открой натальную карту — она подскажет твой путь.",
    ),
    "authSaveUserError": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить профиль. Проверьте подключение и попробуйте снова.",
    ),
    "authUserNotInitialized": MessageLookupByLibrary.simpleMessage(
      "Профиль ещё не готов. Вернитесь на предыдущий шаг и попробуйте снова.",
    ),
    "balanceAllOperations": MessageLookupByLibrary.simpleMessage(
      "Все операции",
    ),
    "balanceBuy": MessageLookupByLibrary.simpleMessage("Купить звёздочёты"),
    "balanceChooseSubscription": MessageLookupByLibrary.simpleMessage(
      "Выбрать подписку",
    ),
    "balanceCurrencyDescription": MessageLookupByLibrary.simpleMessage(
      " — внутренняя валюта. Трать их на расклады, прогнозы и чат с Астро-ботом.",
    ),
    "balanceDeposits": MessageLookupByLibrary.simpleMessage("Начисления"),
    "balanceHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "Пока здесь пусто. Получай или трать звёздочёты — и история появится!",
    ),
    "balanceHistoryLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить историю",
    ),
    "balanceHistoryNoDeposits": MessageLookupByLibrary.simpleMessage(
      "Нет начислений",
    ),
    "balanceHistoryNoWithdrawals": MessageLookupByLibrary.simpleMessage(
      "Нет списаний",
    ),
    "balanceHistoryRefreshError": MessageLookupByLibrary.simpleMessage(
      "Не удалось обновить историю",
    ),
    "balanceHistoryTitle": MessageLookupByLibrary.simpleMessage(
      "История баланса",
    ),
    "balanceLabel": MessageLookupByLibrary.simpleMessage("Баланс"),
    "balanceRewardRetry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "balanceServiceAnakra": MessageLookupByLibrary.simpleMessage(
      "Чат с Астро-ботом — 1 вопрос",
    ),
    "balanceServiceCompatibility": MessageLookupByLibrary.simpleMessage(
      "Дополнительная совместимость",
    ),
    "balanceServiceDream": MessageLookupByLibrary.simpleMessage(
      "Толкование сна",
    ),
    "balanceServiceNatal": MessageLookupByLibrary.simpleMessage(
      "Натальная карта",
    ),
    "balanceServiceTarot": MessageLookupByLibrary.simpleMessage(
      "Расклад Таро: Любовный / Кельтский",
    ),
    "balanceServiceYearForecast": MessageLookupByLibrary.simpleMessage(
      "Персональный прогноз на год",
    ),
    "balanceStarsLabel": m6,
    "balanceSubscriptionDescription": MessageLookupByLibrary.simpleMessage(
      "Оформите подписку — доступ ко всему без ограничений.",
    ),
    "balanceSubscriptionPrompt": MessageLookupByLibrary.simpleMessage(
      "Не хотите считать звёздочки?",
    ),
    "balanceTitle": MessageLookupByLibrary.simpleMessage("Звездочеты"),
    "balanceWhereToSpend": MessageLookupByLibrary.simpleMessage(
      "Куда потратить?",
    ),
    "balanceWithdrawals": MessageLookupByLibrary.simpleMessage("Списания"),
    "birthDateLabel": MessageLookupByLibrary.simpleMessage("Дата рождения"),
    "birthDatePickerTitle": MessageLookupByLibrary.simpleMessage(
      "Выберите дату рождения",
    ),
    "birthPlaceLabel": MessageLookupByLibrary.simpleMessage("Место рождения"),
    "birthTimeLabel": MessageLookupByLibrary.simpleMessage("Время рождения"),
    "birthTimePickerTitle": MessageLookupByLibrary.simpleMessage(
      "Выберите время рождения",
    ),
    "buyAttempts": MessageLookupByLibrary.simpleMessage("Купить попытки"),
    "buyAttemptsLabel": MessageLookupByLibrary.simpleMessage("Купить попытки"),
    "buyAttemptsTitle": MessageLookupByLibrary.simpleMessage("Купить попытки"),
    "buyForPrice": m7,
    "buyNatalCardLabel": m8,
    "buySpecialReadingLabel": m9,
    "buyYearHoroscopeLabel": m10,
    "calendarNextMonth": MessageLookupByLibrary.simpleMessage(
      "Следующий месяц",
    ),
    "calendarPreviousMonth": MessageLookupByLibrary.simpleMessage(
      "Предыдущий месяц",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "cardNumberLabel": MessageLookupByLibrary.simpleMessage("Карта"),
    "celticCrossDescription": MessageLookupByLibrary.simpleMessage(
      "Глубокий и точный расклад на 10 карт. Раскроет суть ситуации, скрытые влияния, поможет принять важное решение.",
    ),
    "choosePackageTitle": MessageLookupByLibrary.simpleMessage("Выбор пакета"),
    "cityConfirmationQuestion": MessageLookupByLibrary.simpleMessage(
      "это ваш город?",
    ),
    "citySaveError": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить город. Попробуйте ещё раз.",
    ),
    "citySearchEmpty": MessageLookupByLibrary.simpleMessage(
      "Города не найдены",
    ),
    "citySearchError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить города. Проверь название или попробуй ещё раз.",
    ),
    "citySelectionChange": MessageLookupByLibrary.simpleMessage("Сменить"),
    "citySelectionConfirm": MessageLookupByLibrary.simpleMessage("Верно"),
    "citySelectionTitle": MessageLookupByLibrary.simpleMessage(
      "Выберите город",
    ),
    "clearMessage": MessageLookupByLibrary.simpleMessage("Очистить сообщение"),
    "coinPackageDescription10": MessageLookupByLibrary.simpleMessage(
      "Хватит на один запрос",
    ),
    "coinPackageDescription120": MessageLookupByLibrary.simpleMessage(
      "Хватит надолго",
    ),
    "coinPackageDescription30": MessageLookupByLibrary.simpleMessage(
      "Хватит на пару прогнозов",
    ),
    "coinPackageDescription300": MessageLookupByLibrary.simpleMessage(
      "Для всех желаний",
    ),
    "coinPackageDescription60": MessageLookupByLibrary.simpleMessage(
      "Самый популярный",
    ),
    "coinPackageFallback": m11,
    "coinPackageFirstMoon": MessageLookupByLibrary.simpleMessage("Первая Луна"),
    "coinPackageRetrogradePath": MessageLookupByLibrary.simpleMessage(
      "Ретроградный Путь",
    ),
    "coinPackageStarPath": MessageLookupByLibrary.simpleMessage(
      "Звёздный Путь",
    ),
    "coinPackageSunlight": MessageLookupByLibrary.simpleMessage("Свет Солнца"),
    "coinPackageUniverseSecret": MessageLookupByLibrary.simpleMessage(
      "Тайна Вселенной",
    ),
    "coinPackagesLoad": MessageLookupByLibrary.simpleMessage(
      "Загрузить пакеты",
    ),
    "coinPackagesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Пакеты пока недоступны",
    ),
    "coinPackagesUnavailableRetry": MessageLookupByLibrary.simpleMessage(
      "Пакеты пока недоступны. Попробуйте позже.",
    ),
    "coinPurchasePending": MessageLookupByLibrary.simpleMessage(
      "Оплата принята. Звёздочёты появятся в течение пары минут.",
    ),
    "commonBack": MessageLookupByLibrary.simpleMessage("Вернуться"),
    "commonBirthDate": MessageLookupByLibrary.simpleMessage("Дата рождения"),
    "commonBirthPlace": MessageLookupByLibrary.simpleMessage("Место рождения"),
    "commonBirthTime": MessageLookupByLibrary.simpleMessage("Время рождения"),
    "commonBuy": MessageLookupByLibrary.simpleMessage("Купить"),
    "commonCancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "commonClear": MessageLookupByLibrary.simpleMessage("Очистить"),
    "commonClose": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "commonContinue": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "commonDescription": MessageLookupByLibrary.simpleMessage("Описание:"),
    "commonError": MessageLookupByLibrary.simpleMessage("Ошибка"),
    "commonHowItAffects": MessageLookupByLibrary.simpleMessage(
      "Как это влияет:",
    ),
    "commonInReadings": MessageLookupByLibrary.simpleMessage("В раскладах:"),
    "commonKeywords": MessageLookupByLibrary.simpleMessage("Ключевые слова:"),
    "commonMeaning": MessageLookupByLibrary.simpleMessage("Значение:"),
    "commonMore": MessageLookupByLibrary.simpleMessage("Еще"),
    "commonName": MessageLookupByLibrary.simpleMessage("Имя"),
    "commonNo": MessageLookupByLibrary.simpleMessage("Нет"),
    "commonOf": MessageLookupByLibrary.simpleMessage("из"),
    "commonOk": MessageLookupByLibrary.simpleMessage("ОК"),
    "commonRetry": MessageLookupByLibrary.simpleMessage("Попробовать снова"),
    "commonSelect": MessageLookupByLibrary.simpleMessage("Выбрать"),
    "commonUnavailable": MessageLookupByLibrary.simpleMessage(
      "Пока недоступно",
    ),
    "commonYes": MessageLookupByLibrary.simpleMessage("Да"),
    "compatibilityAboutPair": MessageLookupByLibrary.simpleMessage(
      "Астрология про вас двоих",
    ),
    "compatibilityAboutPairDescription": MessageLookupByLibrary.simpleMessage(
      "Узнай, как сочетаются ваши стихии, планеты и знаки. Не только про любовь, но и про энергию, поддержку и точки роста.",
    ),
    "compatibilityCalculate": MessageLookupByLibrary.simpleMessage(
      "Рассчитать",
    ),
    "compatibilityCalculationError": MessageLookupByLibrary.simpleMessage(
      "Не удалось рассчитать совместимость. Попробуйте снова.",
    ),
    "compatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "Проверить совместимость",
    ),
    "compatibilityConflicts": MessageLookupByLibrary.simpleMessage("Конфликты"),
    "compatibilityDetailsLabel": MessageLookupByLibrary.simpleMessage(
      "Подробнее о совместимости",
    ),
    "compatibilityFamily": MessageLookupByLibrary.simpleMessage("Семья"),
    "compatibilityFillBirthDate": MessageLookupByLibrary.simpleMessage(
      "Заполните дату рождения в профиле",
    ),
    "compatibilityFillPartner": MessageLookupByLibrary.simpleMessage(
      "Заполните информацию о партнере",
    ),
    "compatibilityHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "История совместимости пуста",
    ),
    "compatibilityHistoryTitle": MessageLookupByLibrary.simpleMessage(
      "История\nсовместимостей",
    ),
    "compatibilityLoadingConsulting": MessageLookupByLibrary.simpleMessage(
      "Звёзды советуются…",
    ),
    "compatibilityLoadingDestinies": MessageLookupByLibrary.simpleMessage(
      "Сопоставляем ваши судьбы…",
    ),
    "compatibilityLoadingSecrets": MessageLookupByLibrary.simpleMessage(
      "Вселенная открывает тайны…",
    ),
    "compatibilityLoadingSigns": MessageLookupByLibrary.simpleMessage(
      "Читаем небесные знаки…",
    ),
    "compatibilityLove": MessageLookupByLibrary.simpleMessage("Любовь"),
    "compatibilityNewPair": MessageLookupByLibrary.simpleMessage(
      "Рассчитать новую пару",
    ),
    "compatibilityNoData": MessageLookupByLibrary.simpleMessage(
      "Нет данных о совместимости",
    ),
    "compatibilityPartnerBirthDate": MessageLookupByLibrary.simpleMessage(
      "Дата рождения партнера",
    ),
    "compatibilityPartnerDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Заполните данные\nвашего партнера",
    ),
    "compatibilityReadMore": MessageLookupByLibrary.simpleMessage("Подробнее"),
    "compatibilityTitle": MessageLookupByLibrary.simpleMessage("Совместимость"),
    "compatibilityUnlockTitle": MessageLookupByLibrary.simpleMessage(
      "Проверь совместимость",
    ),
    "compatibilityYou": MessageLookupByLibrary.simpleMessage("Вы"),
    "contactsDescription": MessageLookupByLibrary.simpleMessage(
      "По любым вопросам вы можете обратиться в поддержку:\nsupport@asteria-calendar.com",
    ),
    "contactsTitle": MessageLookupByLibrary.simpleMessage("Контакты для связи"),
    "contentTranslationUnavailable": MessageLookupByLibrary.simpleMessage(
      "Этот контент пока недоступен. Попробуйте позже.",
    ),
    "currentLocationAutoLabel": MessageLookupByLibrary.simpleMessage(
      "Определено автоматически",
    ),
    "currentLocationManualLabel": MessageLookupByLibrary.simpleMessage(
      "Задано вручную",
    ),
    "dailyLimitTitle": MessageLookupByLibrary.simpleMessage("Лимит на сегодня"),
    "dailyRuneFlipLabel": MessageLookupByLibrary.simpleMessage(
      "Перевернуть руну дня",
    ),
    "dailyRuneLoading": MessageLookupByLibrary.simpleMessage(
      "Загрузка руны дня...",
    ),
    "dailyRuneOpenedLabel": m12,
    "dailyRuneReading": MessageLookupByLibrary.simpleMessage("Разложить руны"),
    "dailyRuneTab": MessageLookupByLibrary.simpleMessage("Руна"),
    "dailyRuneTap": MessageLookupByLibrary.simpleMessage(
      "Нажми на руну, чтобы перевернуть",
    ),
    "dailyRuneTitle": MessageLookupByLibrary.simpleMessage("Руна дня"),
    "dailySymbolTitle": MessageLookupByLibrary.simpleMessage("Символ дня"),
    "dailyTarotFlipLabel": MessageLookupByLibrary.simpleMessage(
      "Перевернуть карту Таро дня",
    ),
    "dailyTarotLoading": MessageLookupByLibrary.simpleMessage(
      "Загрузка карты таро дня...",
    ),
    "dailyTarotOpenedLabel": m13,
    "dailyTarotReading": MessageLookupByLibrary.simpleMessage(
      "Сделать расклад",
    ),
    "dailyTarotTab": MessageLookupByLibrary.simpleMessage("Таро"),
    "dailyTarotTap": MessageLookupByLibrary.simpleMessage(
      "Нажми на карту, чтобы перевернуть",
    ),
    "dailyTarotTitle": MessageLookupByLibrary.simpleMessage("Карта Таро дня"),
    "dayFavorable": MessageLookupByLibrary.simpleMessage("Благоприятный\nдень"),
    "dayFavorableDescription": MessageLookupByLibrary.simpleMessage(
      "Сегодня Луна поддерживает твои начинания. Можно планировать важные дела, действовать смелее и выбирать то, что помогает двигаться вперёд.",
    ),
    "dayNeutral": MessageLookupByLibrary.simpleMessage("Нейтральный\nдень"),
    "dayNeutralDescription": MessageLookupByLibrary.simpleMessage(
      "Это пауза между импульсом и действием. Луна не даёт особой энергии, но и не отнимает её. Не стоит ждать вдохновения — просто береги себя, не перегружай. Тишина внутри — это тоже сила.",
    ),
    "dayTimeOptionLabel": MessageLookupByLibrary.simpleMessage("Дневное время"),
    "dayUnfavorable": MessageLookupByLibrary.simpleMessage(
      "Неблагоприятный\nдень",
    ),
    "dayUnfavorableDescription": MessageLookupByLibrary.simpleMessage(
      "Сегодня лучше снизить нагрузку и не форсировать события. Отложи резкие решения, береги силы и выбирай спокойный темп.",
    ),
    "deckCardLabel": m14,
    "deckGetInsight": MessageLookupByLibrary.simpleMessage("Получить инсайт"),
    "deckHowToUse": MessageLookupByLibrary.simpleMessage(
      "Как пользоваться картами",
    ),
    "deckOpenedCardLabel": m15,
    "defaultLocationMoscow": MessageLookupByLibrary.simpleMessage("Москва"),
    "defaultUserName": MessageLookupByLibrary.simpleMessage("Пользователь"),
    "demoTheme": MessageLookupByLibrary.simpleMessage("Демо темы"),
    "done": MessageLookupByLibrary.simpleMessage("Готово"),
    "dreamCalculationError": MessageLookupByLibrary.simpleMessage(
      "Не удалось расшифровать сон. Попробуйте снова.",
    ),
    "dreamDecode": MessageLookupByLibrary.simpleMessage("Расшифровать"),
    "dreamDecodeAgain": MessageLookupByLibrary.simpleMessage(
      "Расшифровать еще",
    ),
    "dreamDictionaryTitle": MessageLookupByLibrary.simpleMessage(
      "Толкование снов",
    ),
    "dreamGreeting": MessageLookupByLibrary.simpleMessage(
      "Доброго дня!\nЭто Ливея —\nхранительница снов.",
    ),
    "dreamHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "История сонника пуста",
    ),
    "dreamHistoryTitle": MessageLookupByLibrary.simpleMessage(
      "История запросов",
    ),
    "dreamInputHint": MessageLookupByLibrary.simpleMessage(
      "Расскажите о своем сне",
    ),
    "dreamNoData": MessageLookupByLibrary.simpleMessage("Нет данных о соннике"),
    "dreamTellPrompt": MessageLookupByLibrary.simpleMessage(
      "Расскажи ей свой сон —\nона откроет его значение.",
    ),
    "elementAir": MessageLookupByLibrary.simpleMessage("Воздух"),
    "elementEarth": MessageLookupByLibrary.simpleMessage("Земля"),
    "elementFire": MessageLookupByLibrary.simpleMessage("Огонь"),
    "elementWater": MessageLookupByLibrary.simpleMessage("Вода"),
    "emailAccessIssueText": MessageLookupByLibrary.simpleMessage(
      "Указать другую почту",
    ),
    "emailAuthConsentPrefix": MessageLookupByLibrary.simpleMessage(
      "Запрашивая код, вы принимаете условия",
    ),
    "emailAuthMessage": MessageLookupByLibrary.simpleMessage(
      "Введите email — мы отправим шестизначный код подтверждения.",
    ),
    "emailAuthTitle": MessageLookupByLibrary.simpleMessage(
      "Вход или регистрация\nпо почте",
    ),
    "emailCodeSentText": MessageLookupByLibrary.simpleMessage(
      "Код отправлен на почту",
    ),
    "emailDeliveryError": MessageLookupByLibrary.simpleMessage(
      "Не удалось отправить письмо. Попробуйте позже.",
    ),
    "emailHint": MessageLookupByLibrary.simpleMessage("Электронная почта"),
    "emailInvalidError": MessageLookupByLibrary.simpleMessage(
      "Введите корректный email",
    ),
    "emailInvalidOrExpiredCodeError": MessageLookupByLibrary.simpleMessage(
      "Неверный или просроченный код.",
    ),
    "emailNetworkError": MessageLookupByLibrary.simpleMessage(
      "Нет соединения с сервером.",
    ),
    "emailRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Слишком много попыток. Попробуйте позже.",
    ),
    "emailSendCodeError": MessageLookupByLibrary.simpleMessage(
      "Не удалось отправить код. Попробуйте ещё раз.",
    ),
    "emailSignInError": MessageLookupByLibrary.simpleMessage(
      "Не удалось войти. Проверьте подключение и попробуйте ещё раз.",
    ),
    "emailUnavailableError": MessageLookupByLibrary.simpleMessage(
      "Вход по почте временно недоступен.",
    ),
    "emailUnknownError": MessageLookupByLibrary.simpleMessage(
      "Что-то пошло не так. Попробуйте ещё раз.",
    ),
    "energyFocus": MessageLookupByLibrary.simpleMessage("Фокус"),
    "energyOfDay": MessageLookupByLibrary.simpleMessage("Энергия дня"),
    "energyRisks": MessageLookupByLibrary.simpleMessage("Риски"),
    "errorWithDetails": m16,
    "exactTimeUnknown": MessageLookupByLibrary.simpleMessage(
      "Точное время неизвестно",
    ),
    "exactTimeUnknownDescription": MessageLookupByLibrary.simpleMessage(
      "Время рождения влияет на точность расчётов. Если его нет, можно указать примерно. При отсутствии точного времени часть данных может отображаться с меньшей точностью.",
    ),
    "femaleGender": MessageLookupByLibrary.simpleMessage("Женщина"),
    "freeLimitResetsIn": m17,
    "freeRequestsResetIn": m18,
    "genericCheckConnection": MessageLookupByLibrary.simpleMessage(
      "Проверьте подключение к интернету и попробуйте снова.",
    ),
    "genericRefreshError": MessageLookupByLibrary.simpleMessage(
      "Не удалось обновить данные. Попробуйте снова.",
    ),
    "genericSomethingWrong": MessageLookupByLibrary.simpleMessage(
      "Что-то пошло не так",
    ),
    "getCodeText": MessageLookupByLibrary.simpleMessage("Получить код"),
    "getStartedButton": MessageLookupByLibrary.simpleMessage("Начать"),
    "googleSubscriptionPerMonth": m19,
    "googleSubscriptionPerWeek": m20,
    "googleSubscriptionPerYear": m21,
    "googleSubscriptionRecurringTerms": m22,
    "googleSubscriptionTrialTerms": m23,
    "helloText": MessageLookupByLibrary.simpleMessage("Привет"),
    "homeLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить данные",
    ),
    "homeOpenCalendar": MessageLookupByLibrary.simpleMessage("В календарь"),
    "homeProSubscriptionCta": MessageLookupByLibrary.simpleMessage(
      "Попробовать 7 дней бесплатно",
    ),
    "homeProSubscriptionDescription": MessageLookupByLibrary.simpleMessage(
      "Полный доступ к соннику, Таро, AI-астрологу, гороскопу и лунному календарю",
    ),
    "homeProSubscriptionTitle": MessageLookupByLibrary.simpleMessage(
      "Больше знаков\nот звёзд",
    ),
    "homeTitle": MessageLookupByLibrary.simpleMessage("Главная"),
    "horoscopeAdvice": MessageLookupByLibrary.simpleMessage("Советы"),
    "horoscopeCreateError": MessageLookupByLibrary.simpleMessage(
      "Не удалось создать гороскоп.",
    ),
    "horoscopeEmotions": MessageLookupByLibrary.simpleMessage(
      "Эмоции\nи внутренний мир",
    ),
    "horoscopeEssence": MessageLookupByLibrary.simpleMessage("Твоя суть"),
    "horoscopeEssenceDescription": MessageLookupByLibrary.simpleMessage(
      "— сильные стороны и скрытые таланты.",
    ),
    "horoscopeEvolution": MessageLookupByLibrary.simpleMessage("Твоя эволюция"),
    "horoscopeEvolutionDescription": MessageLookupByLibrary.simpleMessage(
      "— путь роста и ключевые перемены.",
    ),
    "horoscopeExamples": MessageLookupByLibrary.simpleMessage("Примеры"),
    "horoscopeFinances": MessageLookupByLibrary.simpleMessage(
      "Финансы\nи материальный\nмир",
    ),
    "horoscopeGeneral": MessageLookupByLibrary.simpleMessage(
      "Общая характеристика",
    ),
    "horoscopeLifeAreas": MessageLookupByLibrary.simpleMessage("Сферы жизни"),
    "horoscopeLifeAreasDescription": MessageLookupByLibrary.simpleMessage(
      "— где тебя ждёт удача и на что обратить внимание.",
    ),
    "horoscopeLifetimeDescription": MessageLookupByLibrary.simpleMessage(
      "Доступ навсегда — читай в любое время, возвращайся и находи новые смыслы в каждом слове.",
    ),
    "horoscopeLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить гороскоп.",
    ),
    "horoscopeLove": MessageLookupByLibrary.simpleMessage(
      "Любовь\nи отношения",
    ),
    "horoscopeMetaphor": MessageLookupByLibrary.simpleMessage(
      "Астрологическая\nметафора",
    ),
    "horoscopePersonalAdvice": MessageLookupByLibrary.simpleMessage(
      "Персональные советы",
    ),
    "horoscopePowerPeriods": MessageLookupByLibrary.simpleMessage(
      "Периоды силы\nи трансформации",
    ),
    "horoscopeTitle": MessageLookupByLibrary.simpleMessage("Гороскоп"),
    "horoscopeTransits": MessageLookupByLibrary.simpleMessage(
      "Актуальные транзиты",
    ),
    "horoscopeWeakPoints": MessageLookupByLibrary.simpleMessage(
      "Слабые места\nи что проработать",
    ),
    "horoscopeWellbeing": MessageLookupByLibrary.simpleMessage("Состояние"),
    "horoscopeWork": MessageLookupByLibrary.simpleMessage(
      "Работа\nи призвание",
    ),
    "initializationError": MessageLookupByLibrary.simpleMessage(
      "Не удалось запустить Asteria",
    ),
    "insightLoadError": MessageLookupByLibrary.simpleMessage(
      "Ошибка получения инсайта. Попробуйте позже.",
    ),
    "keltCardPositionTitle": m24,
    "keltDeckCompletedDescription": MessageLookupByLibrary.simpleMessage(
      "Ты открыл(а) все 10 карт Кельтского креста. Этот расклад дал тебе целостное видение текущей ситуации: от корней в прошлом — до будущих тенденций, от внутренних мотиваций — до внешних влияний.\n✨ Подумай над вопросом, с которым ты пришёл(а) — что сейчас откликается сильнее всего?\nЕсли хочешь глубже осмыслить расклад:\n• Вернись к ключевым картам — позициям 1, 4 и 6\n• Обрати внимание на то, что повторяется\n• Почувствуй, какой совет даёт позиция 10",
    ),
    "keltDeckDescription": MessageLookupByLibrary.simpleMessage(
      "Расклад Таро отвечает на конкретный вопрос. Карты важно открывать по порядку — вместе они складываются в единый ответ. Сначала сформулируй вопрос, затем поочерёдно открывай карты и выбери сферу, к которой он относится.",
    ),
    "keltDeckHowToClosing": MessageLookupByLibrary.simpleMessage(
      "Читай каждую карту внимательно. Не спеши — сначала обрати внимание на позицию, потом на карту. Толкования помогут тебе понять суть происходящего и выбрать лучший путь.",
    ),
    "keltDeckHowToIntroduction": MessageLookupByLibrary.simpleMessage(
      "«Кельтский крест» — это один из самых точных раскладов Таро. Он поможет глубоко разобраться в ситуации, увидеть скрытые причины, внешние влияния и вероятный исход. В раскладе 10 карт, каждая из них отвечает за определённый аспект.",
    ),
    "keltDeckTitle": MessageLookupByLibrary.simpleMessage("Кельтский крест"),
    "keltPosition10Description": MessageLookupByLibrary.simpleMessage(
      "Позиция показывает итог и направление, куда ведёт ситуация.",
    ),
    "keltPosition10Item": MessageLookupByLibrary.simpleMessage(
      "Итог / результат — куда ведёт ситуация, что может случиться, если путь сохранится",
    ),
    "keltPosition10Title": MessageLookupByLibrary.simpleMessage(
      "Итог / результат",
    ),
    "keltPosition1Description": MessageLookupByLibrary.simpleMessage(
      "Позиция показывает, что происходит в момент запроса.",
    ),
    "keltPosition1Item": MessageLookupByLibrary.simpleMessage(
      "Ситуация сейчас — то, что происходит в момент запроса",
    ),
    "keltPosition1Title": MessageLookupByLibrary.simpleMessage(
      "Ситуация сейчас",
    ),
    "keltPosition2Description": MessageLookupByLibrary.simpleMessage(
      "Позиция показывает, что мешает или вызывает трудности.",
    ),
    "keltPosition2Item": MessageLookupByLibrary.simpleMessage(
      "Препятствие — что мешает или вызывает трудности",
    ),
    "keltPosition2Title": MessageLookupByLibrary.simpleMessage("Препятствие"),
    "keltPosition3Description": MessageLookupByLibrary.simpleMessage(
      "Позиция указывает на корень ситуации и глубинную причину.",
    ),
    "keltPosition3Item": MessageLookupByLibrary.simpleMessage(
      "Основа — корень ситуации, глубинная причина",
    ),
    "keltPosition3Title": MessageLookupByLibrary.simpleMessage("Основа"),
    "keltPosition4Description": MessageLookupByLibrary.simpleMessage(
      "Позиция указывает на важные события или влияния из прошлого, которые сформировали текущую ситуацию.",
    ),
    "keltPosition4Item": MessageLookupByLibrary.simpleMessage(
      "Прошлое — события, повлиявшие на текущую ситуацию",
    ),
    "keltPosition4Title": MessageLookupByLibrary.simpleMessage("Прошлое"),
    "keltPosition5Description": MessageLookupByLibrary.simpleMessage(
      "Позиция показывает потенциал и вероятное развитие событий.",
    ),
    "keltPosition5Item": MessageLookupByLibrary.simpleMessage(
      "Потенциал — что может произойти в будущем, если всё пойдёт как идёт",
    ),
    "keltPosition5Title": MessageLookupByLibrary.simpleMessage("Потенциал"),
    "keltPosition6Description": MessageLookupByLibrary.simpleMessage(
      "Позиция показывает ближайшее будущее и то, что проявится совсем скоро.",
    ),
    "keltPosition6Item": MessageLookupByLibrary.simpleMessage(
      "Ближайшее будущее — что произойдёт совсем скоро",
    ),
    "keltPosition6Title": MessageLookupByLibrary.simpleMessage(
      "Ближайшее будущее",
    ),
    "keltPosition7Description": MessageLookupByLibrary.simpleMessage(
      "Позиция раскрывает твой внутренний настрой и поведение.",
    ),
    "keltPosition7Item": MessageLookupByLibrary.simpleMessage(
      "Ты сам(а) — твой внутренний настрой и поведение",
    ),
    "keltPosition7Title": MessageLookupByLibrary.simpleMessage("Ты сам(а)"),
    "keltPosition8Description": MessageLookupByLibrary.simpleMessage(
      "Позиция показывает влияние других людей и внешних факторов.",
    ),
    "keltPosition8Item": MessageLookupByLibrary.simpleMessage(
      "Окружение — влияние других людей, внешние факторы",
    ),
    "keltPosition8Title": MessageLookupByLibrary.simpleMessage("Окружение"),
    "keltPosition9Description": MessageLookupByLibrary.simpleMessage(
      "Позиция даёт совет или предостережение, которое важно учесть.",
    ),
    "keltPosition9Item": MessageLookupByLibrary.simpleMessage(
      "Совет / предостережение — что нужно знать или учесть",
    ),
    "keltPosition9Title": MessageLookupByLibrary.simpleMessage(
      "Совет / предостережение",
    ),
    "legalDocumentUnavailable": MessageLookupByLibrary.simpleMessage(
      "Юридический документ недоступен в этой сборке.",
    ),
    "legalTermsConnector": MessageLookupByLibrary.simpleMessage("и"),
    "licensesDescription": MessageLookupByLibrary.simpleMessage(
      "Icons by HadiSharifani from Figma Community, licensed under CC BY 4.0.",
    ),
    "licensesTitle": MessageLookupByLibrary.simpleMessage(
      "Использованные материалы и лицензии",
    ),
    "limitResetsIn": m25,
    "loading": MessageLookupByLibrary.simpleMessage("Загрузка…"),
    "loadingDataError": MessageLookupByLibrary.simpleMessage(
      "Ошибка загрузки данных",
    ),
    "locationAllowButton": MessageLookupByLibrary.simpleMessage(
      "Разрешить геолокацию",
    ),
    "locationManualButton": MessageLookupByLibrary.simpleMessage(
      "Выбрать город вручную",
    ),
    "locationManualInputHint": MessageLookupByLibrary.simpleMessage("Город"),
    "locationNotConfigured": MessageLookupByLibrary.simpleMessage(
      "Текущая геолокация не задана",
    ),
    "locationPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Не удалось определить геолокацию. Разреши доступ в настройках устройства или введи город вручную.",
    ),
    "logoutButton": MessageLookupByLibrary.simpleMessage("Выйти"),
    "logoutError": MessageLookupByLibrary.simpleMessage(
      "Ошибка выхода из аккаунта",
    ),
    "loveDeckDescription": MessageLookupByLibrary.simpleMessage(
      "6 карт, которые раскроют прошлое, настоящее и возможное будущее вашей пары.\nОткрывай карты по очереди, чтобы узнать, что между вами происходит.",
    ),
    "loveDeckHowToClosing": MessageLookupByLibrary.simpleMessage(
      "Открывай карты по одной и читай их значение в контексте своей ситуации.",
    ),
    "loveDeckHowToIntroduction": MessageLookupByLibrary.simpleMessage(
      "Любовный расклад — это способ лучше понять себя, партнёра и вашу связь. Он состоит из 6 карт, каждая из которых отвечает за важный аспект отношений:",
    ),
    "loveDeckPositionFuture": MessageLookupByLibrary.simpleMessage(
      "Будущее отношений — вероятное развитие ситуации",
    ),
    "loveDeckPositionObstacles": MessageLookupByLibrary.simpleMessage(
      "Что мешает — препятствия или недопонимания",
    ),
    "loveDeckPositionPartnerFeelings": MessageLookupByLibrary.simpleMessage(
      "Его чувства — что он(а) ощущает по отношению к тебе",
    ),
    "loveDeckPositionSharedEnergy": MessageLookupByLibrary.simpleMessage(
      "Общая энергетика — как взаимодействуют ваши энергии",
    ),
    "loveDeckPositionSupport": MessageLookupByLibrary.simpleMessage(
      "Что помогает — ресурсы и поддержка в отношениях",
    ),
    "loveDeckPositionYourFeelings": MessageLookupByLibrary.simpleMessage(
      "Твои чувства — твои эмоции и желания",
    ),
    "loveDeckTagline": MessageLookupByLibrary.simpleMessage(
      "Загляни в чувства партнёра и узнай, к чему ведут ваши отношения",
    ),
    "loveDeckTitle": MessageLookupByLibrary.simpleMessage("Любовный расклад"),
    "loveReadingDescription": MessageLookupByLibrary.simpleMessage(
      "Узнай, что происходит в твоей любовной жизни. Подходит для отношений, сомнений, одиночества или притяжения.",
    ),
    "lunarCalendarTitle": MessageLookupByLibrary.simpleMessage(
      "Лунный календарь",
    ),
    "lunarCareerGrowth": MessageLookupByLibrary.simpleMessage("Карьерный рост"),
    "lunarCosmetology": MessageLookupByLibrary.simpleMessage("Косметология"),
    "lunarCouple": MessageLookupByLibrary.simpleMessage("Пара"),
    "lunarDailyDiet": MessageLookupByLibrary.simpleMessage(
      "Рацион на каждый день",
    ),
    "lunarDay": MessageLookupByLibrary.simpleMessage("лунный день"),
    "lunarEpilationDepilation": MessageLookupByLibrary.simpleMessage(
      "Эпиляция/депиляция",
    ),
    "lunarFamily": MessageLookupByLibrary.simpleMessage("Семья"),
    "lunarForThoseAlone": MessageLookupByLibrary.simpleMessage(
      "Для тех кто один",
    ),
    "lunarFragrancesMagnetism": MessageLookupByLibrary.simpleMessage(
      "Ароматы и магнетизм",
    ),
    "lunarFriends": MessageLookupByLibrary.simpleMessage("Друзья"),
    "lunarGarden": MessageLookupByLibrary.simpleMessage("Сад"),
    "lunarHairColoring": MessageLookupByLibrary.simpleMessage(
      "Окрашивание волос",
    ),
    "lunarHaircut": MessageLookupByLibrary.simpleMessage("Стрижка"),
    "lunarHarvestingPreserving": MessageLookupByLibrary.simpleMessage(
      "Сбор урожая и заготовки",
    ),
    "lunarHealthImmunity": MessageLookupByLibrary.simpleMessage(
      "Здоровье и иммунитет",
    ),
    "lunarHouseplants": MessageLookupByLibrary.simpleMessage(
      "Комнатные растения",
    ),
    "lunarImportantDecisions": MessageLookupByLibrary.simpleMessage(
      "Важные решения",
    ),
    "lunarJobChange": MessageLookupByLibrary.simpleMessage("Смена работы"),
    "lunarManicurePedicure": MessageLookupByLibrary.simpleMessage(
      "Маникюр/педикюр",
    ),
    "lunarMedicalProcedures": MessageLookupByLibrary.simpleMessage(
      "Медицинские процедуры",
    ),
    "lunarMeditations": MessageLookupByLibrary.simpleMessage("Медитации"),
    "lunarPestControl": MessageLookupByLibrary.simpleMessage(
      "Борьба с вредителями",
    ),
    "lunarPhysicalActivitySports": MessageLookupByLibrary.simpleMessage(
      "Физическая активность и спорт",
    ),
    "lunarSex": MessageLookupByLibrary.simpleMessage("Секс"),
    "lunarSkinCare": MessageLookupByLibrary.simpleMessage("Уход за кожей"),
    "lunarSleepRecovery": MessageLookupByLibrary.simpleMessage(
      "Сон и восстановление",
    ),
    "lunarSowingPlanting": MessageLookupByLibrary.simpleMessage(
      "Посев и посадка",
    ),
    "lunarSpaRelaxation": MessageLookupByLibrary.simpleMessage(
      "Спа и расслабление",
    ),
    "lunarTransplantingPricking": MessageLookupByLibrary.simpleMessage(
      "Пересадка и пикировка",
    ),
    "lunarTravel": MessageLookupByLibrary.simpleMessage("Путешествия"),
    "lunarWateringFertilizing": MessageLookupByLibrary.simpleMessage(
      "Полив и подкормка",
    ),
    "lunarWeightLossFasting": MessageLookupByLibrary.simpleMessage(
      "Похудение и разгрузочные дни",
    ),
    "lunarWork": MessageLookupByLibrary.simpleMessage("Работа"),
    "maleGender": MessageLookupByLibrary.simpleMessage("Мужчина"),
    "manage": MessageLookupByLibrary.simpleMessage("Управлять"),
    "moonBackgroundTitle": m26,
    "moonCalendarLoadingDayDescription": MessageLookupByLibrary.simpleMessage(
      "Уточняем текущую дату, фазу Луны и рекомендации.",
    ),
    "moonCalendarLoadingDayTitle": MessageLookupByLibrary.simpleMessage(
      "Загружаем лунный день",
    ),
    "moonDescriptionDefault": MessageLookupByLibrary.simpleMessage(
      "Луна подсказывает сбавить темп, свериться с собой и выбирать то, что поддерживает твою энергию.",
    ),
    "moonDescriptionFirstQuarter": MessageLookupByLibrary.simpleMessage(
      "День требует собранности: выбирай главное, действуй последовательно и не распыляй силы.",
    ),
    "moonDescriptionFullMoon": MessageLookupByLibrary.simpleMessage(
      "Эмоции могут быть ярче обычного. Береги баланс, завершай начатое и оставляй место отдыху.",
    ),
    "moonDescriptionLastQuarter": MessageLookupByLibrary.simpleMessage(
      "Период снижения энергии, лучше замедлиться, избегать перегрузки и не начинать важные дела.",
    ),
    "moonDescriptionNewMoon": MessageLookupByLibrary.simpleMessage(
      "Время мягкого обновления: прислушайся к себе, формулируй намерения и не спеши с резкими решениями.",
    ),
    "moonDescriptionWaningCrescent": MessageLookupByLibrary.simpleMessage(
      "Время восстановления и тишины. Закрывай хвосты, отдыхай и не требуй от себя слишком многого.",
    ),
    "moonDescriptionWaningGibbous": MessageLookupByLibrary.simpleMessage(
      "Хороший период для обмена опытом, благодарности и освобождения от лишнего напряжения.",
    ),
    "moonDescriptionWaxingCrescent": MessageLookupByLibrary.simpleMessage(
      "Энергия постепенно растёт. Хорошо делать первые шаги, укреплять планы и поддерживать внутренний фокус.",
    ),
    "moonDescriptionWaxingGibbous": MessageLookupByLibrary.simpleMessage(
      "Подходит для доработки важных дел, анализа деталей и спокойного движения к результату.",
    ),
    "moonGenericFallbackNotice": MessageLookupByLibrary.simpleMessage(
      "Показан общий лунный календарь",
    ),
    "moonLocationNote": MessageLookupByLibrary.simpleMessage(
      "Учитываем твою локацию и время",
    ),
    "moonLocationSetupDescription": MessageLookupByLibrary.simpleMessage(
      "Лунный день и время восхода зависят от места, где ты находишься сейчас. Разреши геолокацию или введи город вручную.",
    ),
    "moonLocationSetupTitle": MessageLookupByLibrary.simpleMessage(
      "Укажи текущую геолокацию",
    ),
    "moonPhaseChange": MessageLookupByLibrary.simpleMessage("смена фазы Луны"),
    "moonPhaseEventTime": m27,
    "moonPhaseFirstQuarter": MessageLookupByLibrary.simpleMessage(
      "Первая четверть",
    ),
    "moonPhaseFullMoon": MessageLookupByLibrary.simpleMessage("Полнолуние"),
    "moonPhaseLastQuarter": MessageLookupByLibrary.simpleMessage(
      "Последняя четверть",
    ),
    "moonPhaseLoadingDescription": MessageLookupByLibrary.simpleMessage(
      "Уточняем текущую геолокацию и пересчитываем лунные данные.",
    ),
    "moonPhaseLoadingTitle": MessageLookupByLibrary.simpleMessage(
      "Загружаем фазу луны",
    ),
    "moonPhaseNewMoon": MessageLookupByLibrary.simpleMessage("Новолуние"),
    "moonPhaseTitle": MessageLookupByLibrary.simpleMessage("Фаза луны"),
    "moonPhaseUnknown": MessageLookupByLibrary.simpleMessage("Фаза Луны"),
    "moonPhaseWaningCrescent": MessageLookupByLibrary.simpleMessage(
      "Убывающий серп",
    ),
    "moonPhaseWaningGibbous": MessageLookupByLibrary.simpleMessage(
      "Убывающая Луна",
    ),
    "moonPhaseWaxingCrescent": MessageLookupByLibrary.simpleMessage(
      "Растущий серп",
    ),
    "moonPhaseWaxingGibbous": MessageLookupByLibrary.simpleMessage(
      "Растущая Луна",
    ),
    "moonSphereStatusTitle": m28,
    "moonStatusFavorableShort": MessageLookupByLibrary.simpleMessage(
      "благоприятно",
    ),
    "moonStatusNeutralShort": MessageLookupByLibrary.simpleMessage(
      "нейтрально",
    ),
    "moonStatusUnfavorableShort": MessageLookupByLibrary.simpleMessage(
      "неблагоприятно",
    ),
    "nameLabel": MessageLookupByLibrary.simpleMessage("Имя"),
    "natalAccentHouse": m29,
    "natalAccessUnavailable": MessageLookupByLibrary.simpleMessage(
      "Не удалось проверить подписку. Попробуй ещё раз.",
    ),
    "natalBuy": MessageLookupByLibrary.simpleMessage("Открыть натальную карту"),
    "natalCardPriceTitle": m30,
    "natalChartTitle": MessageLookupByLibrary.simpleMessage("Натальная карта"),
    "natalCreateCard": MessageLookupByLibrary.simpleMessage(
      "Создать натальную карту",
    ),
    "natalDestinyDepth": MessageLookupByLibrary.simpleMessage(
      "Судьба и глубина",
    ),
    "natalElementsDescription": MessageLookupByLibrary.simpleMessage(
      "— твой внутренний баланс энергий.",
    ),
    "natalElementsModalities": MessageLookupByLibrary.simpleMessage(
      "Стихии\nи модальности",
    ),
    "natalElementsTab": MessageLookupByLibrary.simpleMessage("Стихии"),
    "natalForeverAccess": MessageLookupByLibrary.simpleMessage(
      "Доступ навсегда",
    ),
    "natalForeverDescription": MessageLookupByLibrary.simpleMessage(
      "Это подробный разбор, который останется с тобой навсегда.",
    ),
    "natalGeneralData": MessageLookupByLibrary.simpleMessage("Общие данные"),
    "natalGenerationFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось создать карту. Попробуй ещё раз.",
    ),
    "natalGetInterpretation": MessageLookupByLibrary.simpleMessage(
      "Получить расшифровку",
    ),
    "natalGrowthLife": MessageLookupByLibrary.simpleMessage("Развитие и жизнь"),
    "natalHousesDescription": MessageLookupByLibrary.simpleMessage(
      "— ключи к сферам жизни и твоим талантам.",
    ),
    "natalHousesThemes": MessageLookupByLibrary.simpleMessage("Дома и темы"),
    "natalIncludedInPro": MessageLookupByLibrary.simpleMessage(
      "Включено в PRO",
    ),
    "natalInsideTitle": MessageLookupByLibrary.simpleMessage(
      "Внутри тебя ждёт",
    ),
    "natalInstantAccess": MessageLookupByLibrary.simpleMessage(
      "Доступ откроется мгновенно после оплаты.",
    ),
    "natalLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить натальную карту. Попробуйте снова.",
    ),
    "natalLoadingCode": MessageLookupByLibrary.simpleMessage(
      "Раскрываем небесный код твоей личности…",
    ),
    "natalLoadingLanguage": MessageLookupByLibrary.simpleMessage(
      "Читаем тайный язык планет…",
    ),
    "natalLoadingPattern": MessageLookupByLibrary.simpleMessage(
      "Соединяем звёзды\nв узор твоей судьбы…",
    ),
    "natalLoadingPortrait": MessageLookupByLibrary.simpleMessage(
      "Вселенная готовит твой звёздный портрет…",
    ),
    "natalMagicSummary": MessageLookupByLibrary.simpleMessage(
      "Магический вывод",
    ),
    "natalMainPositions": MessageLookupByLibrary.simpleMessage(
      "Основные позиции",
    ),
    "natalPaywallIntro": MessageLookupByLibrary.simpleMessage(
      "Натальная карта — это твой уникальный звёздный паспорт, созданный в момент рождения.",
    ),
    "natalPaywallTitle": MessageLookupByLibrary.simpleMessage(
      "Твоя натальная карта",
    ),
    "natalPersonalityFoundation": MessageLookupByLibrary.simpleMessage(
      "Основа личности",
    ),
    "natalPositionsTab": MessageLookupByLibrary.simpleMessage("На сегодня"),
    "natalProAccessDescription": MessageLookupByLibrary.simpleMessage(
      "Без списания звёзд. Созданная карта останется с тобой.",
    ),
    "natalRelationshipsExpression": MessageLookupByLibrary.simpleMessage(
      "Отношения и проявление",
    ),
    "natalStrongHouse": m31,
    "natalSummaryDescription": MessageLookupByLibrary.simpleMessage(
      "— личное послание от Вселенной.",
    ),
    "natalWeakHouse": m32,
    "navHome": MessageLookupByLibrary.simpleMessage("Главная"),
    "navMoon": MessageLookupByLibrary.simpleMessage("Луна"),
    "navPersonal": MessageLookupByLibrary.simpleMessage("Личное"),
    "navPractices": MessageLookupByLibrary.simpleMessage("Практики"),
    "navProfile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "next": MessageLookupByLibrary.simpleMessage("Далее"),
    "nightTimeOptionLabel": MessageLookupByLibrary.simpleMessage(
      "Ночное время",
    ),
    "noSubscriptionQuestion": MessageLookupByLibrary.simpleMessage(
      "Нет подписки?",
    ),
    "notEnoughStarsTitle": MessageLookupByLibrary.simpleMessage(
      "Недостаточно звёздочётов",
    ),
    "offerIncludesTitle": MessageLookupByLibrary.simpleMessage(
      "Вам будут доступны:",
    ),
    "offerProTitle": MessageLookupByLibrary.simpleMessage(
      "Оформить PRO подписку",
    ),
    "offerUnlimitedDescription": MessageLookupByLibrary.simpleMessage(
      "Безлимитные запросы в сонник, Таро, АИ-астролога и запросы совместимости",
    ),
    "onboardPreviewAnakraQuestion": MessageLookupByLibrary.simpleMessage(
      "Привет, почему я чувствую усталость?",
    ),
    "onboardPreviewAnakraReply": MessageLookupByLibrary.simpleMessage(
      "Приветствую тебя ✨ Сегодня твоя энергия просит замедлиться, восстановить внутренний баланс и дать себе больше отдыха 🌙",
    ),
    "onboardPreviewCompatibilityScore": MessageLookupByLibrary.simpleMessage(
      "69%",
    ),
    "onboardPreviewGemini": MessageLookupByLibrary.simpleMessage("Близнецы"),
    "onboardPreviewGeminiDates": MessageLookupByLibrary.simpleMessage(
      "22.05.1994",
    ),
    "onboardPreviewMagicDescription": MessageLookupByLibrary.simpleMessage(
      "Ты пришла в этот мир, чтобы научиться заботиться о себе и других, не теряя границ. В тебе — сила Земли и чувствительность Воды. Луна ведёт тебя через внутренние миры — не забывай слушать её шёпот.",
    ),
    "onboardPreviewMagicTitle": MessageLookupByLibrary.simpleMessage(
      "Магический вывод",
    ),
    "onboardPreviewPersonalState": MessageLookupByLibrary.simpleMessage(
      "Учишься отпускать ожидания и больше доверять потоку.",
    ),
    "onboardPreviewTaurus": MessageLookupByLibrary.simpleMessage("Телец"),
    "onboardPreviewTaurusDates": MessageLookupByLibrary.simpleMessage(
      "13.05.1995",
    ),
    "onboardingEmptyPagesError": MessageLookupByLibrary.simpleMessage(
      "Материалы онбординга недоступны.",
    ),
    "onboardingInvalidPageError": MessageLookupByLibrary.simpleMessage(
      "Эта страница онбординга недоступна.",
    ),
    "onboardingPage1Description": MessageLookupByLibrary.simpleMessage(
      "Луна, таро, натальная карта\nи персональные подсказки каждый день",
    ),
    "onboardingPage1Title": MessageLookupByLibrary.simpleMessage(
      "Asteria\nТвоя вселенная\nпрогнозов и знаков",
    ),
    "onboardingPage2Description": MessageLookupByLibrary.simpleMessage(
      "Фазы луны, энергия дня,\nудачные периоды и подсказки",
    ),
    "onboardingPage2Title": MessageLookupByLibrary.simpleMessage(
      "Узнавай,\nкакой сегодня день\nдля тебя",
    ),
    "onboardingPage3Description": MessageLookupByLibrary.simpleMessage(
      "Расклады, советы\nи персональные интерпретации",
    ),
    "onboardingPage3Title": MessageLookupByLibrary.simpleMessage(
      "Получай ответы\nчерез таро\nи AI-астролога",
    ),
    "onboardingPage4Description": MessageLookupByLibrary.simpleMessage(
      "Натальная карта,\nсовместимость и личные прогнозы",
    ),
    "onboardingPage4Title": MessageLookupByLibrary.simpleMessage(
      "Узнай больше\nо себе и своей\nэнергии",
    ),
    "onboardingPreviewAffirmation": MessageLookupByLibrary.simpleMessage(
      "Моя внутренняя сила растёт с каждым вдохом, наполняя меня уверенностью и спокойствием в любые моменты жизни.",
    ),
    "onboardingPreviewFocusDescription": MessageLookupByLibrary.simpleMessage(
      "День подходит для прорывных идей. Планеты сегодня поддерживают ясность и активность. Хороший день для инициатив.",
    ),
    "onboardingPreviewFocusPhrase": MessageLookupByLibrary.simpleMessage(
      "Высокая концентрация и ресурс",
    ),
    "onboardingPreviewRiskDescription": MessageLookupByLibrary.simpleMessage(
      "Будь осторожна с финансовыми вложениями.",
    ),
    "onboardingPreviewRiskPhrase": MessageLookupByLibrary.simpleMessage(
      "Снижение внимания и фокуса",
    ),
    "openArticleLabel": m33,
    "openCompatibilityLabel": MessageLookupByLibrary.simpleMessage(
      "Открыть совместимость",
    ),
    "openLunarCalendarLabel": MessageLookupByLibrary.simpleMessage(
      "Посмотреть лунный календарь",
    ),
    "openSubscription": MessageLookupByLibrary.simpleMessage(
      "Перейти к подписке",
    ),
    "paidRequestsLeft": m34,
    "paymentAbandonedLocal": MessageLookupByLibrary.simpleMessage(
      "Локально попытка закрыта. Сервер продолжит безопасно обрабатывать возможное подтверждение банка.",
    ),
    "paymentAbandonedServerConfirmed": MessageLookupByLibrary.simpleMessage(
      "Можно создать новый платёж. Позднее банковское подтверждение предыдущей оплаты не потеряется.",
    ),
    "paymentAttemptLeft": MessageLookupByLibrary.simpleMessage(
      "Попытка оставлена",
    ),
    "paymentAuthenticationRequired": MessageLookupByLibrary.simpleMessage(
      "Войдите в аккаунт, чтобы продолжить оплату.",
    ),
    "paymentCoinsCredited": m35,
    "paymentCoinsCreditedBalanceUpdated": m36,
    "paymentConfirming": MessageLookupByLibrary.simpleMessage(
      "Подтверждаем платёж",
    ),
    "paymentConfirmingMessage": MessageLookupByLibrary.simpleMessage(
      "Arc Pay принял оплату. Монеты появятся после серверного начисления.",
    ),
    "paymentContinue": MessageLookupByLibrary.simpleMessage(
      "Продолжить оплату",
    ),
    "paymentCreateError": MessageLookupByLibrary.simpleMessage(
      "Не удалось создать платёж. Попробуйте ещё раз.",
    ),
    "paymentCreateNew": MessageLookupByLibrary.simpleMessage(
      "Создать новый платёж",
    ),
    "paymentCreating": MessageLookupByLibrary.simpleMessage("Создание платежа"),
    "paymentCreatingMessage": MessageLookupByLibrary.simpleMessage(
      "Получаем безопасную ссылку Arc Pay…",
    ),
    "paymentDeclined": MessageLookupByLibrary.simpleMessage(
      "Банк отклонил платёж.",
    ),
    "paymentDiagnostics": m37,
    "paymentExpired": MessageLookupByLibrary.simpleMessage(
      "Срок платежа истёк.",
    ),
    "paymentFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось оплатить",
    ),
    "paymentLeaveAttempt": MessageLookupByLibrary.simpleMessage(
      "Оставить попытку",
    ),
    "paymentLeaveDescription": MessageLookupByLibrary.simpleMessage(
      "Вы сможете создать новый платёж. Если банк уже подтвердил эту оплату, звёзды всё равно будут начислены после проверки сервера.",
    ),
    "paymentLeaveQuestion": MessageLookupByLibrary.simpleMessage(
      "Оставить попытку оплаты?",
    ),
    "paymentManualReview": MessageLookupByLibrary.simpleMessage(
      "Платёж передан на ручную проверку.",
    ),
    "paymentNoPendingPayment": MessageLookupByLibrary.simpleMessage(
      "Нет незавершённого платежа для восстановления.",
    ),
    "paymentNotCompleted": MessageLookupByLibrary.simpleMessage(
      "Платёж не был завершён.",
    ),
    "paymentOpenError": MessageLookupByLibrary.simpleMessage(
      "Не удалось открыть страницу оплаты",
    ),
    "paymentOpenPage": MessageLookupByLibrary.simpleMessage(
      "Открыть страницу оплаты",
    ),
    "paymentPackagesLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить доступные пакеты. Попробуйте позже.",
    ),
    "paymentSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "Способ оплаты выбирается на защищённой странице Arc Pay во время покупки монет.",
    ),
    "paymentSuccess": MessageLookupByLibrary.simpleMessage(
      "Оплата прошла успешно!",
    ),
    "paymentTitle": MessageLookupByLibrary.simpleMessage("Оплата"),
    "paymentWaiting": MessageLookupByLibrary.simpleMessage("Ожидаем оплату"),
    "paymentWaitingMessage": MessageLookupByLibrary.simpleMessage(
      "Завершите оплату во внешнем браузере. Статус обновляется автоматически.",
    ),
    "personalAdviceDay": MessageLookupByLibrary.simpleMessage("Совет на день"),
    "personalAdviceMonth": MessageLookupByLibrary.simpleMessage(
      "Совет на месяц",
    ),
    "personalAdviceWeek": MessageLookupByLibrary.simpleMessage(
      "Совет на неделю",
    ),
    "personalCharacter": MessageLookupByLibrary.simpleMessage("Характер"),
    "personalDefaultDescription": MessageLookupByLibrary.simpleMessage(
      "Ты родился(ась) под знаком стабильности и глубокой чувствительности. У тебя сильная связь с эмоциями и интуицией.",
    ),
    "personalElement": MessageLookupByLibrary.simpleMessage("Стихия"),
    "personalEnergy": MessageLookupByLibrary.simpleMessage("Энергия"),
    "personalFavorablePeriods": MessageLookupByLibrary.simpleMessage(
      "Благоприятные периоды",
    ),
    "personalFinances": MessageLookupByLibrary.simpleMessage("Финансы"),
    "personalFinancialStability": MessageLookupByLibrary.simpleMessage(
      "Финансовая стабильность",
    ),
    "personalForecastPrice": m38,
    "personalGreeting": m39,
    "personalGreetingGeneral": MessageLookupByLibrary.simpleMessage("Привет!"),
    "personalHarmony": MessageLookupByLibrary.simpleMessage(
      "Баланс внутренней гармонии",
    ),
    "personalImpactAreas": MessageLookupByLibrary.simpleMessage(
      "Влияние на сферы",
    ),
    "personalInfoDescription": MessageLookupByLibrary.simpleMessage(
      "Укажи дату, время и место рождения — и Вселенная заговорит с тобой.",
    ),
    "personalInfoSubtitle": MessageLookupByLibrary.simpleMessage(
      "Настройся на ритмы Луны и открой натальную карту — она подскажет твой путь.",
    ),
    "personalInfoTitle": MessageLookupByLibrary.simpleMessage(
      "Познай свою космическую суть",
    ),
    "personalLove": MessageLookupByLibrary.simpleMessage("Любовь"),
    "personalLoveRelationships": MessageLookupByLibrary.simpleMessage(
      "Любовь\nи отношения",
    ),
    "personalMonthKeyThemes": MessageLookupByLibrary.simpleMessage(
      "Ключевые темы\nмесяца",
    ),
    "personalMonthPurchaseDescription": MessageLookupByLibrary.simpleMessage(
      "Подробный персональный гороскоп на месяц доступен за единоразовую покупку.",
    ),
    "personalMonthTab": MessageLookupByLibrary.simpleMessage("На месяц"),
    "personalOpenChart": MessageLookupByLibrary.simpleMessage("Открыть карту"),
    "personalOpenForecast": MessageLookupByLibrary.simpleMessage(
      "Открой прогноз",
    ),
    "personalOpenFree": MessageLookupByLibrary.simpleMessage(
      "Открыть бесплатно",
    ),
    "personalPlanet": MessageLookupByLibrary.simpleMessage("Планета"),
    "personalTodayFree": MessageLookupByLibrary.simpleMessage(
      "Подробный персональный гороскоп на сегодня доступен бесплатно.",
    ),
    "personalTodayTab": MessageLookupByLibrary.simpleMessage("На сегодня"),
    "personalUnlock": MessageLookupByLibrary.simpleMessage("Разблокировать"),
    "personalUnlockKeyTheme": MessageLookupByLibrary.simpleMessage(
      "Открыть ключевую тему",
    ),
    "personalUnlockWeaknesses": MessageLookupByLibrary.simpleMessage(
      "Открыть слабые места",
    ),
    "personalWeaknessesPrice": m40,
    "personalWeekPurchaseDescription": MessageLookupByLibrary.simpleMessage(
      "Подробный персональный гороскоп на неделю доступен за единоразовую покупку.",
    ),
    "personalWeekTab": MessageLookupByLibrary.simpleMessage("На неделю"),
    "personalYearForecast": MessageLookupByLibrary.simpleMessage(
      "Персональный гороскоп на год",
    ),
    "personalYourHoroscope": MessageLookupByLibrary.simpleMessage(
      "Твой гороскоп",
    ),
    "placeLabel": MessageLookupByLibrary.simpleMessage("Место рождения"),
    "planetChiron": MessageLookupByLibrary.simpleMessage("Хирон"),
    "planetJupiter": MessageLookupByLibrary.simpleMessage("Юпитер"),
    "planetLilith": MessageLookupByLibrary.simpleMessage("Лилит"),
    "planetMars": MessageLookupByLibrary.simpleMessage("Марс"),
    "planetMercury": MessageLookupByLibrary.simpleMessage("Меркурий"),
    "planetMoon": MessageLookupByLibrary.simpleMessage("Луна"),
    "planetNeptune": MessageLookupByLibrary.simpleMessage("Нептун"),
    "planetNorthNode": MessageLookupByLibrary.simpleMessage("Северный узел"),
    "planetParsFortunae": MessageLookupByLibrary.simpleMessage(
      "Колесо Фортуны",
    ),
    "planetPluto": MessageLookupByLibrary.simpleMessage("Плутон"),
    "planetSaturn": MessageLookupByLibrary.simpleMessage("Сатурн"),
    "planetSelena": MessageLookupByLibrary.simpleMessage("Селена"),
    "planetSouthNode": MessageLookupByLibrary.simpleMessage("Южный узел"),
    "planetSun": MessageLookupByLibrary.simpleMessage("Солнце"),
    "planetUranus": MessageLookupByLibrary.simpleMessage("Уран"),
    "planetVenus": MessageLookupByLibrary.simpleMessage("Венера"),
    "planetVertex": MessageLookupByLibrary.simpleMessage("Вертекс"),
    "playerAddedFavorite": MessageLookupByLibrary.simpleMessage(
      "Добавлено в избранное",
    ),
    "playerClose": MessageLookupByLibrary.simpleMessage("Закрыть плеер"),
    "playerFavorite": MessageLookupByLibrary.simpleMessage("В избранном"),
    "playerFavoriteError": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить избранное",
    ),
    "playerHideTranscript": MessageLookupByLibrary.simpleMessage(
      "Свернуть текст",
    ),
    "playerMetadata": MessageLookupByLibrary.simpleMessage(
      "Аффирмация  ·  1 мин 15 сек",
    ),
    "playerPause": MessageLookupByLibrary.simpleMessage("Пауза"),
    "playerPlay": MessageLookupByLibrary.simpleMessage("Воспроизвести"),
    "playerPlayError": MessageLookupByLibrary.simpleMessage(
      "Не удалось воспроизвести запись",
    ),
    "playerPosition": MessageLookupByLibrary.simpleMessage(
      "Позиция воспроизведения",
    ),
    "playerRemovedFavorite": MessageLookupByLibrary.simpleMessage(
      "Удалено из избранного",
    ),
    "playerRepeat": MessageLookupByLibrary.simpleMessage("Повтор записи"),
    "playerRepeatOff": MessageLookupByLibrary.simpleMessage("Повтор выключен"),
    "playerRepeatOn": MessageLookupByLibrary.simpleMessage("Повтор включён"),
    "playerReplay": MessageLookupByLibrary.simpleMessage("Прослушать ещё раз"),
    "playerShare": MessageLookupByLibrary.simpleMessage(
      "Поделиться аффирмацией",
    ),
    "playerShareError": MessageLookupByLibrary.simpleMessage(
      "Не удалось открыть меню «Поделиться»",
    ),
    "playerShowTranscript": MessageLookupByLibrary.simpleMessage(
      "Показать весь текст",
    ),
    "policyText": MessageLookupByLibrary.simpleMessage(
      "Политики конфиденциальности",
    ),
    "privacySummary": MessageLookupByLibrary.simpleMessage(
      "Политика конфиденциальности объясняет, какие персональные данные обрабатывает Asteria, для каких целей и как они защищаются.",
    ),
    "profileAbout": MessageLookupByLibrary.simpleMessage("О приложении"),
    "profileAchievements": MessageLookupByLibrary.simpleMessage(
      "Мои достижения",
    ),
    "profileConfirmEmailDelete": MessageLookupByLibrary.simpleMessage(
      "Подтвердите почту для удаления аккаунта",
    ),
    "profileDeleteAccount": MessageLookupByLibrary.simpleMessage(
      "Удаление аккаунта",
    ),
    "profileDeleteAccountQuestion": MessageLookupByLibrary.simpleMessage(
      "Вы точно хотите удалить аккаунт?",
    ),
    "profileDeleteError": MessageLookupByLibrary.simpleMessage(
      "Не удалось удалить аккаунт. Попробуйте снова.",
    ),
    "profileLogoutQuestion": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти из приложения?",
    ),
    "profileLogoutTitle": MessageLookupByLibrary.simpleMessage(
      "Выход из приложения",
    ),
    "profileOpenWebsiteError": MessageLookupByLibrary.simpleMessage(
      "Не удалось открыть сайт",
    ),
    "profileShop": MessageLookupByLibrary.simpleMessage("Магазин"),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Профиль"),
    "purchaseConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Подтвердите покупку",
    ),
    "purchaseDayHoroscope": MessageLookupByLibrary.simpleMessage(
      "Открыть гороскоп на день",
    ),
    "purchaseErrorTryAgain": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка. Попробуйте позже.",
    ),
    "purchaseForCoinsLabel": m41,
    "purchaseForPrice": m42,
    "purchaseGoToChat": MessageLookupByLibrary.simpleMessage("Перейти в чат"),
    "purchaseMonthHoroscope": MessageLookupByLibrary.simpleMessage(
      "Открыть гороскоп на месяц",
    ),
    "purchaseNotEnoughGeneric": MessageLookupByLibrary.simpleMessage(
      "Недостаточно для покупки",
    ),
    "purchaseNotEnoughReading": MessageLookupByLibrary.simpleMessage(
      "Недостаточно для покупки расклада",
    ),
    "purchaseNotEnoughRequests": MessageLookupByLibrary.simpleMessage(
      "Недостаточно для покупки запросов",
    ),
    "purchaseRequestsTitle": m43,
    "purchaseRequired": MessageLookupByLibrary.simpleMessage(
      "Для покупки требуется",
    ),
    "purchaseSuccess": MessageLookupByLibrary.simpleMessage("Покупка успешна"),
    "purchaseTitle": MessageLookupByLibrary.simpleMessage("Покупка"),
    "purchaseWeekHoroscope": MessageLookupByLibrary.simpleMessage(
      "Открыть гороскоп на неделю",
    ),
    "purchaseYearHoroscope": MessageLookupByLibrary.simpleMessage(
      "Открыть гороскоп на год",
    ),
    "purchasedAttemptsAdd": MessageLookupByLibrary.simpleMessage(
      "Купленные попытки суммируются с бесплатными",
    ),
    "purchasedAttemptsCombine": MessageLookupByLibrary.simpleMessage(
      "Купленные попытки суммируются с бесплатными",
    ),
    "questionCoinPrice": m44,
    "readingComplete": MessageLookupByLibrary.simpleMessage(
      "Твой расклад завершён",
    ),
    "readingTimeMinutes": MessageLookupByLibrary.simpleMessage("мин"),
    "refreshDailyRuneLabel": MessageLookupByLibrary.simpleMessage(
      "Обновить руну дня",
    ),
    "refreshDailyTarotLabel": MessageLookupByLibrary.simpleMessage(
      "Обновить карту Таро дня",
    ),
    "refreshReadingLabel": MessageLookupByLibrary.simpleMessage(
      "Обновить расклад",
    ),
    "refreshRuneSpreadLabel": MessageLookupByLibrary.simpleMessage(
      "Обновить расклад рун",
    ),
    "refreshTarotSpreadLabel": MessageLookupByLibrary.simpleMessage(
      "Обновить расклад Таро",
    ),
    "requestLimitResetIn": m45,
    "requestPackageCount": m46,
    "requestPackageForCoins": m47,
    "requestsExhausted": MessageLookupByLibrary.simpleMessage(
      "Ты использовал все запросы.\nХочешь продолжить?",
    ),
    "requestsLeftCount": m48,
    "requestsLeftOfTotal": m49,
    "requestsLeftThisWeek": m50,
    "requestsRemaining": m51,
    "resendCodeButtonText": MessageLookupByLibrary.simpleMessage(
      "Отправить новый код",
    ),
    "resendCodeText": MessageLookupByLibrary.simpleMessage(
      "Отправить код повторно через",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "rewardAvailableNextMonth": MessageLookupByLibrary.simpleMessage(
      "Доступно в следующем месяце",
    ),
    "rewardCompleteOnboarding": MessageLookupByLibrary.simpleMessage(
      "Завершить онбординг",
    ),
    "rewardCompleted": MessageLookupByLibrary.simpleMessage("Выполнено"),
    "rewardGranted": MessageLookupByLibrary.simpleMessage(
      "Звездочёты начислены",
    ),
    "rewardLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить задания.",
    ),
    "rewardLoginStreak": MessageLookupByLibrary.simpleMessage(
      "Зайти 5 дней подряд",
    ),
    "rewardMonthly": MessageLookupByLibrary.simpleMessage("1 раз в месяц"),
    "rewardOneTime": MessageLookupByLibrary.simpleMessage("Разово"),
    "rewardReadArticles": MessageLookupByLibrary.simpleMessage(
      "Прочитать 3 статьи",
    ),
    "rewardShare": MessageLookupByLibrary.simpleMessage(
      "Поделиться в соцсетях",
    ),
    "rewardShareError": MessageLookupByLibrary.simpleMessage(
      "Не удалось поделиться Asteria.",
    ),
    "rewardShareSubject": MessageLookupByLibrary.simpleMessage(
      "Asteria — персональный астрологический помощник",
    ),
    "rewardShareText": m52,
    "rewardStartError": MessageLookupByLibrary.simpleMessage(
      "Не удалось запустить задания.",
    ),
    "rewardTarotReading": MessageLookupByLibrary.simpleMessage(
      "Раскинуть Таро",
    ),
    "rewardsHowEarn": MessageLookupByLibrary.simpleMessage("Как заработать?"),
    "runeLockedLabel": m53,
    "runeOpenFuture": MessageLookupByLibrary.simpleMessage(
      "Открыть руну будущего",
    ),
    "runeOpenFutureMeaning": m54,
    "runeOpenLabel": m55,
    "runeOpenPast": MessageLookupByLibrary.simpleMessage(
      "Открыть руну прошлого",
    ),
    "runeOpenPastMeaning": m56,
    "runeOpenPresent": MessageLookupByLibrary.simpleMessage(
      "Открыть руну настоящего",
    ),
    "runeOpenPresentMeaning": m57,
    "runeRefreshSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Обновление руны дня доступно только по подписке. Оформите подписку, чтобы получать новую руну каждый день.",
    ),
    "runesEmpty": MessageLookupByLibrary.simpleMessage("Руны не найдены"),
    "runesFuture": MessageLookupByLibrary.simpleMessage("Будущее"),
    "runesFutureDescription": MessageLookupByLibrary.simpleMessage(
      "Куда всё движется. Возможный исход, направление или подсказка на путь вперёд.",
    ),
    "runesHowToIntroduction": MessageLookupByLibrary.simpleMessage(
      "Руны — это не гадание в прямом смысле. Это символы, которые раскрывают твои внутренние знания, помогают услышать интуицию и найти ответы, которые уже внутри тебя.",
    ),
    "runesHowToReminder": MessageLookupByLibrary.simpleMessage(
      "Руны — это не пригов и не предсказание судьбы. Это зеркало, в котором ты можешь увидеть себя яснее. Пользуйся ими с уважением, и они будут мудрыми спутниками на твоём пути.",
    ),
    "runesHowToSteps": MessageLookupByLibrary.simpleMessage(
      "1. Сформулируй намерение. Задай себе вопрос или определи сферу, где хочешь получить подсказку.\n\n2. Настройся на момент. Успокой мысли. Руны работают лучше, когда ты в тишине — внутренней и внешней.\n\n3. Выбери руну. Не думай слишком долго. Просто доверься себе — твоя руна тебя найдёт.\n\n4. Прочитай значение. Обрати внимание на символ и его суть. Не ищи «да» или «нет» — смотри глубже: о чём руна хочет сказать?\n\n5. Прислушайся к себе. Почувствуй, как значение откликается. Руны дают направление, но ты сам(а) идёшь по пути.",
    ),
    "runesHowToUse": MessageLookupByLibrary.simpleMessage(
      "Как пользоваться рунами",
    ),
    "runesInsightSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Получение инсайта по раскладу доступно только по подписке. Оформите подписку, чтобы узнать значение вашего расклада.",
    ),
    "runesLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить руны.",
    ),
    "runesPast": MessageLookupByLibrary.simpleMessage("Прошлое"),
    "runesPastDescription": MessageLookupByLibrary.simpleMessage(
      "Что привело тебя к текущей точке. Опыт, уроки, корень вопроса.",
    ),
    "runesPresent": MessageLookupByLibrary.simpleMessage("Настоящее"),
    "runesPresentDescription": MessageLookupByLibrary.simpleMessage(
      "Где ты находишься сейчас. Внутреннее состояние, текущие влияния.",
    ),
    "runesSpreadDailyLimit": MessageLookupByLibrary.simpleMessage(
      "Вы уже использовали возможность смены расклада сегодня. Завтра вы сможете снова выбрать новый расклад. Или оформите подписку для неограниченной смены расклада.",
    ),
    "runesSpreadDescription": MessageLookupByLibrary.simpleMessage(
      "Каждая руна в этом раскладе отвечает за определённую часть твоей ситуации:",
    ),
    "runesSpreadTitle": MessageLookupByLibrary.simpleMessage("Расклад рун"),
    "runesTabAll": MessageLookupByLibrary.simpleMessage("Все руны"),
    "runesTabDay": MessageLookupByLibrary.simpleMessage("Руна дня"),
    "runesTabSpread": MessageLookupByLibrary.simpleMessage("Расклад"),
    "runesTapToFlip": MessageLookupByLibrary.simpleMessage(
      "Нажми на руну, чтобы перевернуть",
    ),
    "runesTitle": MessageLookupByLibrary.simpleMessage("Руны"),
    "saveButtonLoadingText": MessageLookupByLibrary.simpleMessage(
      "Сохранение...",
    ),
    "savings": MessageLookupByLibrary.simpleMessage("Выгода"),
    "settingsCurrentLocationDescription": MessageLookupByLibrary.simpleMessage(
      "Используем текущий город для лунного календаря и фазы луны. Место рождения остаётся только для натальной карты.",
    ),
    "settingsDailyAffirmations": MessageLookupByLibrary.simpleMessage(
      "Ежедневные аффирмации",
    ),
    "settingsDailyHoroscope": MessageLookupByLibrary.simpleMessage(
      "Гороскоп на день",
    ),
    "settingsGeolocation": MessageLookupByLibrary.simpleMessage("Геолокация"),
    "settingsLunarCalendar": MessageLookupByLibrary.simpleMessage(
      "Лунный календарь",
    ),
    "settingsNotifications": MessageLookupByLibrary.simpleMessage(
      "Уведомления",
    ),
    "settingsPushNotifications": MessageLookupByLibrary.simpleMessage(
      "Push уведомления",
    ),
    "shopAfterPurchase": MessageLookupByLibrary.simpleMessage("После покупки:"),
    "shopBalance": MessageLookupByLibrary.simpleMessage("Баланс:"),
    "shopDecreaseQuantity": MessageLookupByLibrary.simpleMessage(
      "Уменьшить количество",
    ),
    "shopIncreaseQuantity": MessageLookupByLibrary.simpleMessage(
      "Увеличить количество",
    ),
    "shopItemCount": m58,
    "shopItemSuffix": MessageLookupByLibrary.simpleMessage("шт"),
    "shopItemsLeft": MessageLookupByLibrary.simpleMessage("Осталось"),
    "shopLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить товары",
    ),
    "shopNoProducts": MessageLookupByLibrary.simpleMessage("Товары не найдены"),
    "shopProceed": MessageLookupByLibrary.simpleMessage("Перейти"),
    "shopPurchaseComplete": MessageLookupByLibrary.simpleMessage(
      "Покупка завершена",
    ),
    "shopPurchaseError": MessageLookupByLibrary.simpleMessage(
      "Не удалось совершить покупку",
    ),
    "shopQuantityQuestion": MessageLookupByLibrary.simpleMessage(
      "Сколько хотите купить?",
    ),
    "shopRequired": MessageLookupByLibrary.simpleMessage("Требуется"),
    "shopSubtitle": MessageLookupByLibrary.simpleMessage(
      "Потрать звёздочёты на полезные функции",
    ),
    "shopTitle": MessageLookupByLibrary.simpleMessage("Магазин"),
    "shopUnitPrice": MessageLookupByLibrary.simpleMessage("цена за 1"),
    "shopUnitPriceValue": m59,
    "specialReadingsTitle": MessageLookupByLibrary.simpleMessage(
      "Особые расклады",
    ),
    "sphereBeauty": MessageLookupByLibrary.simpleMessage("Красота"),
    "sphereGarden": MessageLookupByLibrary.simpleMessage("Садоводство"),
    "sphereHealth": MessageLookupByLibrary.simpleMessage("Здоровье"),
    "sphereRelationships": MessageLookupByLibrary.simpleMessage("Отношения"),
    "sphereSelect": MessageLookupByLibrary.simpleMessage("Выберите сферу"),
    "sphereSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Оформите подписку, чтобы узнать, как Луна влияет на вас",
    ),
    "sphereWorkRest": MessageLookupByLibrary.simpleMessage("Работа и отдых"),
    "step1Description": MessageLookupByLibrary.simpleMessage(
      "Изучите все функции приложения и начните использовать их уже сегодня",
    ),
    "step1Title": MessageLookupByLibrary.simpleMessage(
      "Откройте для себя новые возможности",
    ),
    "step2Description": MessageLookupByLibrary.simpleMessage(
      "Интуитивно понятный интерфейс поможет вам быстро освоить приложение",
    ),
    "step2Title": MessageLookupByLibrary.simpleMessage("Быстро и удобно"),
    "step3Description": MessageLookupByLibrary.simpleMessage(
      "Присоединяйтесь к сообществу и начните использовать все возможности",
    ),
    "step3Title": MessageLookupByLibrary.simpleMessage("Готовы начать?"),
    "storeProductsLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить товары магазина. Попробуйте ещё раз.",
    ),
    "storePurchaseCanceled": MessageLookupByLibrary.simpleMessage(
      "Покупка отменена.",
    ),
    "storePurchaseFailedError": MessageLookupByLibrary.simpleMessage(
      "Не удалось завершить покупку. Попробуйте ещё раз.",
    ),
    "storePurchaseStartError": MessageLookupByLibrary.simpleMessage(
      "Не удалось начать покупку. Попробуйте ещё раз.",
    ),
    "storePurchaseSupportError": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка покупки. Обратитесь в поддержку.",
    ),
    "storePurchaseVerificationError": MessageLookupByLibrary.simpleMessage(
      "Не удалось подтвердить покупку. Если деньги списаны, обратитесь в поддержку.",
    ),
    "storeRestorePurchasesError": MessageLookupByLibrary.simpleMessage(
      "Не удалось восстановить покупки. Попробуйте ещё раз.",
    ),
    "storeSignInRequiredError": MessageLookupByLibrary.simpleMessage(
      "Войдите в аккаунт, чтобы продолжить покупку.",
    ),
    "subscribeTitle": MessageLookupByLibrary.simpleMessage("Оформить подписку"),
    "subscriptionAccessUntil": MessageLookupByLibrary.simpleMessage(
      "Доступ сохранится до\n",
    ),
    "subscriptionActivated": MessageLookupByLibrary.simpleMessage(
      "Подписка активирована",
    ),
    "subscriptionActivationPending": MessageLookupByLibrary.simpleMessage(
      "Оплата принята. Подписка активируется в течение пары минут.",
    ),
    "subscriptionActive": MessageLookupByLibrary.simpleMessage(
      "Подписка\nPRO активна",
    ),
    "subscriptionAvailableToYou": MessageLookupByLibrary.simpleMessage(
      "Вам доступны:",
    ),
    "subscriptionBenefitAffirmations": MessageLookupByLibrary.simpleMessage(
      "Неограниченные аффирмации по разным категориям",
    ),
    "subscriptionBenefitCompatibility": MessageLookupByLibrary.simpleMessage(
      "Неограниченные запросы совместимости",
    ),
    "subscriptionBenefitHoroscope": MessageLookupByLibrary.simpleMessage(
      "Полный персональный гороскоп без ограничений",
    ),
    "subscriptionBenefitMoon": MessageLookupByLibrary.simpleMessage(
      "Все сферы в лунном календаре",
    ),
    "subscriptionBenefitUnlimited": MessageLookupByLibrary.simpleMessage(
      "Безлимитные запросы в сонник, Таро и АИ-астролога",
    ),
    "subscriptionBenefitsTitle": MessageLookupByLibrary.simpleMessage(
      "Что даёт подписка",
    ),
    "subscriptionCancelDescription": MessageLookupByLibrary.simpleMessage(
      "Действие всех сервисов будет\nсохранено до конца оплаченного\nпериода",
    ),
    "subscriptionCancelQuestion": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите\nотключить подписку?",
    ),
    "subscriptionChoosePlan": MessageLookupByLibrary.simpleMessage(
      "Выберите план",
    ),
    "subscriptionConfirmingCard": MessageLookupByLibrary.simpleMessage(
      "Подтверждаем привязку карты и первый платёж…",
    ),
    "subscriptionConnect": MessageLookupByLibrary.simpleMessage(
      "Подключить PRO",
    ),
    "subscriptionDisable": MessageLookupByLibrary.simpleMessage(
      "Отключить подписку",
    ),
    "subscriptionInactive": MessageLookupByLibrary.simpleMessage(
      "Подписка PRO\nне активна",
    ),
    "subscriptionInactiveDescription": MessageLookupByLibrary.simpleMessage(
      "Расширенные функции\nс PRO — подключайте\nи отключайте в любой\nмомент.",
    ),
    "subscriptionInfoDescription": MessageLookupByLibrary.simpleMessage(
      "Подписка предоставляет доступ к расширенным функциям приложения:\n• Безлимитные запросы в Сонник, Таро и АИ-Астролога\n• Полный персональный гороскоп без ограничений\n• Подробные разборы в Лунном календаре\n• Полный доступ к совместимости\n• Неограниченные аффирмации\nОплата списывается с вашей учётной записи App Store или Google Play после подтверждения покупки. Подписка продлевается автоматически, если автопродление не отключено как минимум за 24 часа до окончания текущего периода. Управлять подпиской можно в настройках учётной записи магазина. Платежи не возвращаются за неиспользованный период. Подробнее см. в Пользовательском соглашении.",
    ),
    "subscriptionInfoTitle": MessageLookupByLibrary.simpleMessage(
      "Информация о подписке",
    ),
    "subscriptionLoadPlans": MessageLookupByLibrary.simpleMessage(
      "Загрузить тарифы",
    ),
    "subscriptionNextPayment": MessageLookupByLibrary.simpleMessage(
      "Следующее списание\nбудет произведено",
    ),
    "subscriptionNextPaymentInline": MessageLookupByLibrary.simpleMessage(
      "Следующее списание будет\nпроизведено ",
    ),
    "subscriptionNextPaymentOn": m60,
    "subscriptionNoPurchasesToRestore": MessageLookupByLibrary.simpleMessage(
      "Покупки для восстановления не найдены",
    ),
    "subscriptionOnlyTitle": MessageLookupByLibrary.simpleMessage(
      "Только по подписке",
    ),
    "subscriptionOpenPaymentAgain": MessageLookupByLibrary.simpleMessage(
      "Открыть оплату снова",
    ),
    "subscriptionPlansUnavailable": MessageLookupByLibrary.simpleMessage(
      "Подписки пока недоступны. Попробуйте позже.",
    ),
    "subscriptionPurchasesRestored": m61,
    "subscriptionRestoreInProgress": MessageLookupByLibrary.simpleMessage(
      "Восстанавливаем покупки…",
    ),
    "subscriptionRestorePurchases": MessageLookupByLibrary.simpleMessage(
      "Восстановить покупки",
    ),
    "subscriptionTitle": MessageLookupByLibrary.simpleMessage("Подписка"),
    "subscriptionUnlimitedAccess": MessageLookupByLibrary.simpleMessage(
      "Оформите подписку — доступ ко всему без ограничений.",
    ),
    "tarotCardsEmpty": MessageLookupByLibrary.simpleMessage("Карты не найдены"),
    "tarotCardsTitle": MessageLookupByLibrary.simpleMessage("Карты Таро"),
    "tarotChooseSphere": MessageLookupByLibrary.simpleMessage(
      "Выбери сферу,\nчтобы получить инсайт",
    ),
    "tarotHowToReminder": MessageLookupByLibrary.simpleMessage(
      "Не забывай: трактовка — это не приговор, а подсказка. Ты всегда сама управляешь своей жизнью.",
    ),
    "tarotHowToSteps": MessageLookupByLibrary.simpleMessage(
      "1. Настройся. Подумай о своём вопросе или ситуации.\n\n2. Выбери карту или сделай расклад — интуитивно или по инструкциям.\n\n3. Читай значение каждой карты и сопоставляй с текущими событиями.\n\n4. Доверься своей интуиции — Таро не даёт жёстких приговоров, а помогает увидеть скрытое.\n\n5. Выберите сферу жизни, к которой относится ваш вопрос, чтобы получить более точную интерпретацию.",
    ),
    "tarotInsightSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Получение инсайта по раскладу доступно только по подписке. Оформите подписку, чтобы узнать значение вашего расклада.",
    ),
    "tarotLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить карты Таро.",
    ),
    "tarotLockedCardLabel": m62,
    "tarotOpenCardLabel": m63,
    "tarotOpenSpreadCard": m64,
    "tarotOpenedSpreadCard": m65,
    "tarotRefreshSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Обновление карты Таро доступно только по подписке. Оформите подписку, чтобы получать новую карту каждый день.",
    ),
    "tarotSphereCareer": MessageLookupByLibrary.simpleMessage(
      "Карьера и деньги",
    ),
    "tarotSphereFamily": MessageLookupByLibrary.simpleMessage("Семья и дом"),
    "tarotSphereHealth": MessageLookupByLibrary.simpleMessage(
      "Здоровье и энергия",
    ),
    "tarotSphereLove": MessageLookupByLibrary.simpleMessage(
      "Любовь и отношения",
    ),
    "tarotSphereSelfRealization": MessageLookupByLibrary.simpleMessage(
      "Самореализация",
    ),
    "tarotSphereSpirituality": MessageLookupByLibrary.simpleMessage(
      "Духовность",
    ),
    "tarotSpreadDailyLimit": MessageLookupByLibrary.simpleMessage(
      "Вы уже использовали возможность смены расклада сегодня. Завтра вы сможете снова выбрать новый расклад. Или оформите подписку для неограниченной смены расклада.",
    ),
    "tarotSpreadDescription": MessageLookupByLibrary.simpleMessage(
      "Расклад Таро отвечает на конкретный вопрос.\nКарты важно открывать по порядку — вместе они складываются в единый ответ.\nСначала сформулируй вопрос, затем поочерёдно открывай карты и выбери сферу, к которой он относится.",
    ),
    "tarotSpreadTitle": MessageLookupByLibrary.simpleMessage("Расклад Таро"),
    "tarotTabAllCards": MessageLookupByLibrary.simpleMessage("Все карты"),
    "tarotTabDay": MessageLookupByLibrary.simpleMessage("Карта дня"),
    "tarotTabSpread": MessageLookupByLibrary.simpleMessage("Расклад"),
    "tarotTapToFlip": MessageLookupByLibrary.simpleMessage(
      "Нажми на карту, чтобы перевернуть",
    ),
    "unknownTimeOptionLabel": MessageLookupByLibrary.simpleMessage(
      "Время неизвестно",
    ),
    "unlimited": MessageLookupByLibrary.simpleMessage("Безлимит"),
    "userNotFoundError": MessageLookupByLibrary.simpleMessage(
      "Пользователь не найден",
    ),
    "viewHistory": MessageLookupByLibrary.simpleMessage("Посмотреть историю"),
    "yearHoroscopeChapters": MessageLookupByLibrary.simpleMessage(
      "Каждая глава включает:",
    ),
    "yearHoroscopeIntro": MessageLookupByLibrary.simpleMessage(
      "Открой карту своей судьбы и загляни в будущее, которое ждёт именно тебя.",
    ),
    "yearHoroscopePriceTitle": m66,
  };
}
