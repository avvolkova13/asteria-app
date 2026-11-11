import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/articles_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final exclude in [null, 'article3']) {
    testWidgets(
      'article cards grow together and retain height after a swipe (exclude $exclude)',
      (tester) async {
        const longTitle =
            'Как меняется лунное небо от новолуния до полнолуния и что мы видим с Земли';
        const first = ArticleModel(
          id: 'article1',
          title: 'Луна',
          category: 'Небо',
          intro: '',
          text: '',
          conclusion: '',
          timeToRead: 5,
        );
        di.registerSingleton<ContentProvider>(
          _Articles([
            first,
            first.copyWith(id: 'article2', title: longTitle),
            first.copyWith(id: 'article3', title: 'Звёзды'),
          ]),
        );
        addTearDown(() async => di.reset());
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [AppLocalizations.delegate],
            home: Builder(
              builder: (context) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.6)),
                  child: Scaffold(
                    body: SingleChildScrollView(
                      child: ArticlesSectionWidget(excludeArticleId: exclude),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final shortText = find.text(first.title);
        final longText = find.text(longTitle);
        Rect cardFor(Finder title) => tester.getRect(
          find
              .ancestor(
                of: title,
                matching: find.byWidgetPredicate(
                  (w) => w is Container && w.foregroundDecoration != null,
                ),
              )
              .first,
        );
        final short = cardFor(shortText);
        final long = cardFor(longText);
        expect(long.height, greaterThan(252));
        expect(short.bottom, long.bottom);
        expect(short.top, long.top);
        expect(tester.getBottomLeft(longText).dy, lessThan(long.bottom));
        await tester.drag(shortText, const Offset(-180, 0));
        await tester.pumpAndSettle();
        expect(cardFor(longText).left, lessThan(long.left));
        expect(cardFor(longText).height, short.height);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _Articles extends Fake implements ContentProvider {
  _Articles(this.articles);
  @override
  final List<ArticleModel> articles;
}
