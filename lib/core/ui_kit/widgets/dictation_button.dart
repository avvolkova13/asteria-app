import 'dart:async';

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

/// Inserts a completed transcription into the editable draft at its caret.
class DictationButton extends StatefulWidget {
  const DictationButton({
    super.key,
    required this.controller,
    required this.onActiveChanged,
    this.enabled = true,
    this.showLabel = false,
  });

  final TextEditingController controller;
  final ValueChanged<bool> onActiveChanged;
  final bool enabled;
  final bool showLabel;

  @override
  State<DictationButton> createState() => _DictationButtonState();
}

class _DictationButtonState extends State<DictationButton>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('asteria/dictation');
  String? _session;
  bool _finishing = false;

  bool get _russian => Localizations.localeOf(context).languageCode == 'ru';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final session = _session;
    if (session != null) unawaited(_cancelNative(session));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = _session;
    if (state == AppLifecycleState.paused && session != null) {
      _complete();
      unawaited(_cancelNative(session));
    }
  }

  Future<void> _cancelNative(String session) async {
    try {
      await _channel.invokeMethod<void>('cancel', {'id': session});
    } on PlatformException {
      // The native session may already have stopped during an interruption.
    } on MissingPluginException {
      // The platform does not support this channel.
    }
  }

  void _complete() {
    setState(() {
      _session = null;
      _finishing = false;
    });
    widget.onActiveChanged(false);
  }

  bool _canApply(String session) =>
      mounted &&
      _session == session &&
      ModalRoute.isCurrentOf(context) != false;

  Future<void> _start() async {
    if (_session != null || !widget.enabled) return;
    final session = const Uuid().v4();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final controller = widget.controller;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _session = session);
    widget.onActiveChanged(true);
    try {
      final transcript = await _channel
          .invokeMethod<String>('start', {'id': session, 'locale': locale})
          .timeout(const Duration(seconds: 75));
      final text = transcript?.trim();
      if (_canApply(session) &&
          identical(controller, widget.controller) &&
          text != null &&
          text.isNotEmpty) {
        _insert(controller, text);
      }
    } on PlatformException catch (error) {
      if (_canApply(session)) _showError(error.code);
    } on MissingPluginException {
      if (_canApply(session)) _showError('unavailable');
    } on TimeoutException {
      await _cancelNative(session);
      if (_canApply(session)) _showError('unavailable');
    } finally {
      if (mounted && _session == session) _complete();
    }
  }

  Future<void> _stop(String session) async {
    setState(() => _finishing = true);
    try {
      await _channel.invokeMethod<void>('stop', {'id': session});
    } on PlatformException {
      await _cancelNative(session);
      if (_canApply(session)) _showError('unavailable');
      if (mounted && _session == session) _complete();
    } on MissingPluginException {
      if (_canApply(session)) _showError('unavailable');
      if (mounted && _session == session) _complete();
    }
  }

  void _insert(TextEditingController controller, String transcript) {
    final original = controller.text;
    final selection = controller.selection;
    final withinText = selection.isValid && selection.end <= original.length;
    final start = withinText ? selection.start : original.length;
    final end = withinText ? selection.end : original.length;
    final before = original.substring(0, start);
    final after = original.substring(end);
    final leftSpace = before.isNotEmpty && before.trimRight() == before
        ? ' '
        : '';
    final rightSpace =
        after.isNotEmpty &&
            after.trimLeft() == after &&
            !RegExp(r'^[,.!?;:…)]').hasMatch(after)
        ? ' '
        : '';
    final insert = '$leftSpace$transcript$rightSpace';
    controller.value = TextEditingValue(
      text: '$before$insert$after',
      selection: TextSelection.collapsed(offset: start + insert.length),
    );
  }

  void _showError(String code) {
    final ru = _russian;
    final message = switch (code) {
      'permission_denied' =>
        ru
            ? 'Разрешите доступ к\u00a0микрофону и\u00a0распознаванию речи в\u00a0настройках.'
            : 'Allow microphone and speech access in Settings.',
      'no_speech' =>
        ru
            ? 'Речь не распознана. Попробуйте ещё раз.'
            : 'No speech detected. Try again.',
      _ =>
        ru
            ? 'Диктовка сейчас недоступна. Можно ввести текст вручную.'
            : 'Dictation is unavailable. You can type your text.',
    };
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      return const SizedBox.shrink();
    }
    final ru = _russian;
    final session = _session;
    final label = _finishing
        ? (ru ? 'Обрабатываем речь…' : 'Processing speech…')
        : session == null
        ? (ru ? 'Надиктовать' : 'Dictate')
        : (ru ? 'Остановить диктовку' : 'Stop dictation');
    final onPressed = _finishing
        ? null
        : session != null
        ? () => _stop(session)
        : widget.enabled
        ? _start
        : null;
    final icon = session == null
        ? ClayAssetIcon('assets/icons/sub/voice.svg', width: 24, height: 24)
        : const Icon(
            Icons.stop_rounded,
            size: 24,
            color: AppColorsDark.linkGold,
          );
    if (widget.showLabel) {
      return LotusButtons.text(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: AppColors.textInverse),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(child: Text(label)),
          ],
        ),
      );
    }
    return SizedBox.square(
      dimension: 44,
      child: LotusButtons.icon(
        tooltip: label,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Opacity(
          opacity: onPressed == null ? 0.45 : 1,
          child: LotusIconSurface(diameter: 37, child: icon),
        ),
      ),
    );
  }
}
