import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'lotus_feedback.dart';

/// Keeps multi-line links inside their paragraph while showing the touched
/// range. The recognizer owns cancellation when a surrounding scroll wins.
mixin LotusInlineLinks<T extends StatefulWidget> on State<T> {
  final _recognizers = <String, TapGestureRecognizer>{};
  String? _pressedLink;

  void _highlight(String? id) {
    if (mounted && _pressedLink != id) setState(() => _pressedLink = id);
  }

  TextSpan linkSpan({
    required String id,
    required String text,
    required TextStyle style,
    required VoidCallback onTap,
  }) {
    final recognizer = _recognizers.putIfAbsent(id, () {
      void release() {
        if (_pressedLink == id) _highlight(null);
      }

      final tap = TapGestureRecognizer();
      tap.onTapDown = (_) => _highlight(id);
      tap.onTapUp = (_) => release();
      tap.onTapCancel = release;
      return tap;
    });
    recognizer.onTap = LotusFeedback.action(onTap);
    final ink = style.color ?? Theme.of(context).colorScheme.onSurface;
    return TextSpan(
      text: text,
      recognizer: recognizer,
      style: _pressedLink == id
          ? style.copyWith(backgroundColor: ink.withValues(alpha: .22))
          : style,
    );
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    super.dispose();
  }
}
