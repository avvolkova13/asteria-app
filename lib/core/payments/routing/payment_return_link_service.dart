import 'dart:async';

import 'package:app_links/app_links.dart';

class PaymentReturnLinkService {
  final AppLinks _appLinks;
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();
  StreamSubscription<Uri>? _subscription;
  Uri? _pending;

  PaymentReturnLinkService({AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  Stream<Uri> get links => _controller.stream;

  void initialize() {
    _subscription ??= _appLinks.uriLinkStream.listen((uri) {
      if (!_isPaymentReturn(uri)) return;
      _pending = uri;
      _controller.add(uri);
    });
  }

  Uri? takePending() {
    final result = _pending;
    _pending = null;
    return result;
  }

  bool _isPaymentReturn(Uri uri) =>
      uri.scheme == 'asteria' && uri.host == 'payment-return';

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
