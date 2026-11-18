import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/widgets/closed_content_modal.dart';
import 'package:asteria_app/core/ui_kit/widgets/shared_purchase_modal.dart';
import 'package:asteria_app/features/balance/presentation/balance_history_controller.dart';
import 'package:asteria_app/features/balance/presentation/screens/balance_history_screen.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/subscription/native_subscription_analytics_test.dart'
    as sub;
import 'commerce_review_capture_test.dart'
    show ReviewBinding, ReviewWallet, reviewPump;

void expectWholeWord(WidgetTester tester, String label, String word) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
  final start = label.indexOf(word);
  expect(start, greaterThanOrEqualTo(0));
  expect(
    paragraph.getBoxesForSelection(
      TextSelection(baseOffset: start, extentOffset: start + word.length),
    ),
    hasLength(1),
    reason: 'The complete word "$word" must remain on one line.',
  );
}

void main() {
  ReviewBinding();
  setUpAll(() async {
    for (final font in [
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
  });
  for (final kind in ['confirmation', 'locked', 'history']) {
    testWidgets('$kind keeps complete words at 320 with text scale 2', (
      tester,
    ) async {
      final wallet = ReviewWallet();
      final user = sub.TestUser();
      final controller = BalanceHistoryController(
        loadPage: ({required filter, beforeSequence}) async =>
            const WalletHistoryPageModel(
              items: [],
              hasEntries: false,
              nextBeforeSequence: null,
            ),
      );
      controller.setAccount('review');
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
        wallet.dispose();
        user.dispose();
        tester.view.reset();
      });
      final lang = kind == 'locked' ? 'en' : 'ru';
      final Widget screen = kind == 'history'
          ? BalanceHistoryView(
              controller: controller,
              balance: 230,
              hasPro: false,
              onBack: () {},
            )
          : Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: kind == 'locked'
                    ? ClosedContentModal(description: 'PRO', onSubscribe: () {})
                    : SharedPurchaseModal(
                        purchaseTitle: 'Любовный расклад',
                        price: 10,
                        onPurchase: () async {},
                      ),
              ),
            );
      await reviewPump(tester, screen, wallet, user, lang, true);
      expect(tester.takeException(), isNull);
      final l10n = AppLocalizations.current;
      switch (kind) {
        case 'confirmation':
          expectWholeWord(tester, l10n.purchaseConfirmTitle, 'Подтвердите');
        case 'locked':
          expectWholeWord(tester, l10n.subscriptionOnlyTitle, 'Subscription');
        case 'history':
          expectWholeWord(tester, l10n.balanceHistoryEmpty, 'звёздочёты');
      }
    });
  }
}
