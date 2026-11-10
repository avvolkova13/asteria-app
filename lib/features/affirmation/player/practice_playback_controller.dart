import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Controls the bundled recording. Position and completion come from the
/// platform player, so interruptions and seeks also update the transcript.
class PracticePlaybackController extends ChangeNotifier
    with WidgetsBindingObserver {
  PracticePlaybackController() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const _channel = MethodChannel('asteria/practice-audio');
  static int _nextSession = 0;
  final int _session = ++_nextSession;

  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 75);
  bool _playing = false;
  bool _looping = false;
  bool _complete = false;
  bool _closed = false;
  bool _reading = false;
  int _revision = 0;
  Future<void>? _loading;
  Timer? _poll;

  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _playing;
  bool get isLooping => _looping;
  bool get isComplete => _complete;

  Future<void> initialize() {
    if (_closed) return Future.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      await _update('load');
    } catch (_) {
      _loading = null;
      rethrow;
    }
  }

  Future<void> toggle() => _command('toggle');

  Future<void> seek(Duration position) => _command('seek', {
    'ms': position.inMilliseconds.clamp(0, _duration.inMilliseconds),
  });

  Future<void> setLooping(bool value) => _command('loop', {'value': value});

  Future<void> _command(
    String method, [
    Map<String, Object> data = const {},
  ]) async {
    if (_closed) return;
    await initialize();
    if (!_closed) await _update(method, data);
  }

  Future<void> _update(
    String method, [
    Map<String, Object> data = const {},
  ]) async {
    final revision = ++_revision;
    final state = await _channel.invokeMapMethod<String, Object?>(method, {
      'session': _session,
      ...data,
    });
    if (_closed || revision != _revision || state == null) return;
    _duration = Duration(milliseconds: state['duration'] as int);
    _position = Duration(milliseconds: state['position'] as int);
    _playing = state['playing'] as bool;
    _looping = state['loop'] as bool;
    _complete = state['complete'] as bool;
    if (_playing) {
      _poll ??= Timer.periodic(
        const Duration(milliseconds: 120),
        (_) => _readPosition(),
      );
    } else {
      _poll?.cancel();
      _poll = null;
    }
    notifyListeners();
  }

  Future<void> _readPosition() async {
    if (_closed || _reading) return;
    _reading = true;
    try {
      await _update('state');
    } on PlatformException {
      _poll?.cancel();
      _poll = null;
      _playing = false;
      if (!_closed) notifyListeners();
    } finally {
      _reading = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.hidden ||
            state == AppLifecycleState.paused) &&
        _loading != null) {
      unawaited(_command('pause').catchError(_reportPlatformError));
    }
  }

  static void _reportPlatformError(Object error, StackTrace stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'practice audio',
      ),
    );
  }

  @override
  void dispose() {
    _closed = true;
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (_loading != null) {
      unawaited(
        _channel
            .invokeMethod<void>('close', {'session': _session})
            .catchError(_reportPlatformError),
      );
    }
    super.dispose();
  }
}
