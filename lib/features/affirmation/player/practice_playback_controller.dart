import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Controls the bundled recording. Position and completion come from the
/// platform player, so interruptions and seeks also update the transcript.
class PracticePlaybackController extends ChangeNotifier
    with WidgetsBindingObserver {
  PracticePlaybackController({this.audioAsset, Duration? previewDuration})
    : _preview = previewDuration != null,
      _duration = previewDuration ?? const Duration(seconds: 75) {
    WidgetsBinding.instance.addObserver(this);
  }

  static const _channel = MethodChannel('asteria/practice-audio');
  static int _nextSession = 0;
  final int _session = ++_nextSession;

  final String? audioAsset;
  final _previewClock = Stopwatch();
  Duration _previewStart = Duration.zero;
  bool _preview;
  Duration _position = Duration.zero;
  Duration _duration;
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
  bool get isPreview => _preview;
  bool get isPlaying => _playing;
  bool get isLooping => _looping;
  bool get isComplete => _complete;

  Future<void> initialize() {
    if (_closed) return Future.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      if (_preview) {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        if (_closed) return;
        if (!manifest.listAssets().contains(audioAsset)) return;
        _preview = false;
      }
      await _update('load', {if (audioAsset != null) 'asset': audioAsset!});
    } catch (_) {
      _loading = null;
      rethrow;
    }
  }

  Future<void> continueWithoutAudio() async {
    if (_closed || _preview) return;
    _revision++;
    _playing = false;
    _syncPoll();
    _preview = true;
    _loading = Future<void>.value();
    try {
      await _channel.invokeMethod<void>('close', {'session': _session});
    } on PlatformException {
      // The failing audio session is unavailable.
    } on MissingPluginException {
      // There is no platform player on this device.
    }
    if (!_closed) _updatePreview('toggle', const {});
  }

  Future<void> toggle() => _command('toggle');

  Future<void> pause() => _command('pause');

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
    if (_closed) return;
    if (_preview) {
      _updatePreview(method, data);
    } else {
      await _update(method, data);
    }
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
    _syncPoll();
    notifyListeners();
  }

  void _updatePreview(String method, Map<String, Object> data) {
    if (_playing) {
      final elapsed = _previewStart + _previewClock.elapsed;
      _complete = !_looping && elapsed >= _duration;
      _position = _looping
          ? Duration(
              milliseconds: elapsed.inMilliseconds % _duration.inMilliseconds,
            )
          : _complete
          ? _duration
          : elapsed;
      if (_complete) _playing = false;
    }

    switch (method) {
      case 'toggle':
        if (_playing) {
          _playing = false;
        } else {
          if (_complete) _position = Duration.zero;
          _complete = false;
          _playing = true;
        }
      case 'pause':
        _playing = false;
      case 'seek':
        _position = Duration(milliseconds: data['ms'] as int);
        _complete = _position >= _duration;
        if (_complete) _playing = false;
      case 'loop':
        _looping = data['value'] as bool;
    }
    if (method != 'state' || !_playing) {
      _previewStart = _position;
      _previewClock
        ..stop()
        ..reset();
      if (_playing) _previewClock.start();
    }
    _syncPoll();
    notifyListeners();
  }

  void _syncPoll() {
    if (_playing) {
      _poll ??= Timer.periodic(
        const Duration(milliseconds: 120),
        (_) => _readPosition(),
      );
    } else {
      _poll?.cancel();
      _poll = null;
    }
  }

  Future<void> _readPosition() async {
    if (_closed || _reading) return;
    if (_preview) {
      _updatePreview('state', const {});
      return;
    }
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
      unawaited(pause().catchError(_reportPlatformError));
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
    _previewClock.stop();
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (_loading != null && !_preview) {
      unawaited(
        _channel
            .invokeMethod<void>('close', {'session': _session})
            .catchError(_reportPlatformError),
      );
    }
    super.dispose();
  }
}
