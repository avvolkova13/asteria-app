import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resolves Russian devices to the Russian policy', () {
    expect(
      AppLocaleService.resolveLocales(const [Locale('ru', 'RU')]),
      const Locale('ru'),
    );
  });

  test('preserves supported English regions', () {
    for (final country in const ['US', 'CA', 'GB', 'AU']) {
      expect(
        AppLocaleService.resolveLocales([Locale('en', country)]),
        Locale('en', country),
      );
    }
  });

  test('uses US English for unknown languages and English regions', () {
    expect(
      AppLocaleService.resolveLocales(const [Locale('de', 'DE')]),
      const Locale('en', 'US'),
    );
    expect(
      AppLocaleService.resolveLocales(const [Locale('en', 'NZ')]),
      const Locale('en', 'US'),
    );
  });

  test('notifies when the effective system locale changes', () {
    final service = AppLocaleService(
      platformLocales: const [Locale('en', 'US')],
    );
    var notifications = 0;
    service.addListener(() => notifications++);

    service.updatePlatformLocales(const [Locale('en', 'GB')]);

    expect(service.effectiveLocale, const Locale('en', 'GB'));
    expect(service.languageTag, 'en-GB');
    expect(service.contentLanguage, 'en');
    expect(notifications, 1);
    service.dispose();
  });

  test('regional English ARB overrides use local spelling', () async {
    final us = (await AppLocalizations.load(
      const Locale('en', 'US'),
    )).onboardingPage2Description;
    final gb = (await AppLocalizations.load(
      const Locale('en', 'GB'),
    )).onboardingPage2Description;
    final au = (await AppLocalizations.load(
      const Locale('en', 'AU'),
    )).onboardingPage2Description;
    final ca = (await AppLocalizations.load(
      const Locale('en', 'CA'),
    )).onboardingPage2Description;

    expect(us, contains('favorable'));
    expect(gb, contains('favourable'));
    expect(au, contains('favourable'));
    expect(ca, contains('favourable'));
  });

  test('plural messages interpolate the count', () async {
    final en = await AppLocalizations.load(const Locale('en', 'US'));

    expect(en.requestsLeftCount(1), '1 request left');
    expect(en.requestsLeftCount(5), '5 requests left');
    expect(en.freeLimitResetsIn(2), 'Your free requests reset in 2 days.');
    expect(en.requestPackageForCoins(1, 15), '1 request for 15 Star Coins');
    expect(en.requestPackageForCoins(3, 30), '3 requests for 30 Star Coins');

    final ru = await AppLocalizations.load(const Locale('ru'));
    expect(ru.requestsLeftCount(1), 'Остался 1 запрос');
    expect(ru.requestsLeftCount(5), 'Осталось 5 запросов');
    expect(ru.requestPackageForCoins(3, 30), '3 запроса за 30 звёзд');
  });
}
