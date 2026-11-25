import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/compatibility_history_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_initial_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compability_results.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';

import 'free_attempt.dart';

class FreeConflictScenario extends StatelessWidget {
  const FreeConflictScenario({super.key, required this.onOpenTarot});
  final VoidCallback onOpenTarot;

  @override
  Widget build(BuildContext context) {
    final users = di.get<UserProvider>();
    return ListenableBuilder(
      listenable: users,
      builder: (_, _) => _PairEntry(
        key: ValueKey(users.currentUser?.id),
        users: users,
        onOpenTarot: onOpenTarot,
      ),
    );
  }
}

class _PairEntry extends StatefulWidget {
  const _PairEntry({super.key, required this.users, required this.onOpenTarot});
  final UserProvider users;
  final VoidCallback onOpenTarot;

  @override
  State<_PairEntry> createState() => _PairEntryState();
}

class _PairEntryState extends State<_PairEntry> {
  late final owner = widget.users.currentUser?.id;
  bool checking = true, available = false, failed = false;
  bool _usesPro = false;
  int _latestCheck = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _check();
    });
  }

  Future<bool> _check() async {
    final check = ++_latestCheck;
    final access = di.get<MonetizationProvider>();
    bool allowed = false, error = false, usesPro = false;
    try {
      await access.refreshForAccess();
      final current = owner != null && access.isCurrentUser(owner!);
      usesPro = current && access.effectivePro;
      allowed = current && canUseScenarioRequest(access, 'compatibility');
    } catch (_) {
      error = true;
    }
    if (!mounted ||
        check != _latestCheck ||
        widget.users.currentUser?.id != owner) {
      return false;
    }
    setState(() {
      checking = false;
      failed = error;
      available = allowed;
      _usesPro = usesPro;
    });
    return allowed;
  }

  void _returnToForm() {
    if (!mounted) return;
    final route = ModalRoute.of(context)!;
    Navigator.of(context).popUntil((r) => r == route);
    setState(() => checking = true);
    _check();
  }

  void _open(WidgetBuilder builder) {
    final users = widget.users;
    final uid = owner;
    Navigator.of(context)
        .push<void>(
          CupertinoPageRoute(
            builder: (_) => ListenableBuilder(
              listenable: users,
              builder: (context, _) {
                if (!mounted || users.currentUser?.id != uid) {
                  return CompatibilityLayout(
                    showRequestsBadge: false,
                    child: Text(context.l10n.compatibilityNoData),
                  );
                }
                return CompatibilityLayout(
                  showRequestsBadge: false,
                  child: builder(context),
                );
              },
            ),
          ),
        )
        .then((_) {
          if (mounted &&
              !checking &&
              ModalRoute.of(context)?.isCurrent == true) {
            _check();
          }
        });
  }

  void _history() {
    _open(
      (_) => CompatibilityHistoryScreen(
        user: widget.users.currentUser,
        onNewPairPressed: _returnToForm,
        onItemTap: _result,
      ),
    );
  }

  void _result(SavedCompatibilityModel pair) {
    _open(
      (_) => CompabilityResults(
        compatibilityData: pair.compatibilityData,
        sourceLocale: pair.locale,
        hisBirthdate: pair.firstBirthdate.toShortDate(),
        herBirthdate: pair.secondBirthdate.toShortDate(),
        highlightConflicts: true,
        onNewPairPressed: _returnToForm,
        onHistoryPressed: _history,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.users.currentUser;
    final hasDate = user?.personalInfo?.birthDate?.birthDate != null;
    if (!checking && available && hasDate) {
      return CreateCompatibilityInitialScreen(
        checkFreeAttempt: _check,
        showFreeAttemptNotice: !_usesPro,
        onHistoryPressed: _history,
        onCreated: _result,
      );
    }
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return CompatibilityLayout(
      showRequestsBadge: false,
      child: checking
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  failed
                      ? (ru
                            ? 'Не удалось проверить бесплатные попытки.'
                            : 'Couldn’t check your free readings.')
                      : !hasDate && available
                      ? context.l10n.compatibilityFillBirthDate
                      : _usesPro
                      ? context.l10n.compatibilityNoData
                      : (ru
                            ? 'Бесплатных разборов для новой пары сейчас нет.'
                            : 'No free readings for a new pair are available right now.'),
                  style: context.textTheme.inverseUrbanistRegular16,
                ),
                const SizedBox(height: 16),
                if (user?.compatibilityHistory.isNotEmpty == true)
                  CompatibilityGradientButton(
                    text: context.l10n.viewHistory,
                    onPressed: _history,
                  ),
                if (failed)
                  TextButton(
                    onPressed: _check,
                    child: Text(context.l10n.commonRetry),
                  ),
                TextButton(
                  onPressed: widget.onOpenTarot,
                  child: Text(
                    ru
                        ? 'Открыть карту для двоих'
                        : 'Open a card for the two of you',
                  ),
                ),
              ],
            ),
    );
  }
}
