import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _usage =
    'dart tool/audit_motion.dart <local-vm-uri-file> [--allow-native-popups]';
const _treeMethod = 'ext.flutter.inspector.getRootWidgetTree';
const _limit =
    'Mounted widget snapshot only. Explicit offstage markers are skipped. '
    'Retained pages and clipped content can still be counted. '
    'Counts describe ancestry of content widgets, not visible pixels, actual '
    'playback, interaction, unmounted routes or later loading states.';

const _contentTypes = {
  'RichText',
  'RawImage',
  'CustomPaint',
  'EditableText',
  'CircularProgressIndicator',
  'LinearProgressIndicator',
  'Texture',
  'PlatformViewLink',
  'UiKitView',
};
const _dialogTypes = {
  'Dialog',
  'AlertDialog',
  'SimpleDialog',
  'CupertinoAlertDialog',
  'CupertinoActionSheet',
};
final _typePattern = RegExp(r'^_?[A-Z][A-Za-z0-9_]*');

class _Surface {
  _Surface(this.type, this.modal);
  final String type;
  final bool modal;
  int entrance = 0;
  int native = 0;
  final missing = <String, int>{};
}

class _Snapshot {
  _Snapshot(this.allowNativePopups);
  final bool allowNativePopups;
  final surfaces = <_Surface>[];
  final types = <String, int>{};
  int nodes = 0;
  int groups = 0;
  int offstage = 0;

  void walk(
    Map node, {
    _Surface? surface,
    bool entrance = false,
    bool native = false,
  }) {
    if (node['style'] == 'offstage') {
      offstage++;
      return;
    }
    nodes++;
    final description = node['description'];
    final type = description is String
        ? _typePattern.stringMatch(description)
        : null;
    // Each OverlayEntry has its own ancestry, including dialogs over an existing page.
    if (type == '_OverlayEntryWidget') {
      surface = null;
      native = false;
      entrance = false;
    }
    if (type == 'AsteriaEntrance') {
      entrance = true;
      groups++;
    }
    final local = node['createdByLocalProject'] == true;
    if (type != null) {
      final screen =
          local &&
          (type.endsWith('Screen') ||
              type == 'ScenarioPage' ||
              type == 'ScenarioPicker');
      final modal =
          local &&
          (type.endsWith('Sheet') ||
              type.endsWith('Dialog') ||
              type.endsWith('Modal'));
      // Flutter Material's modal route owns this private sheet wrapper.
      final popupRoot = type == '_ModalBottomSheet';
      final dialog = _dialogTypes.contains(type);
      native = native || popupRoot;
      if (screen || modal || popupRoot || (dialog && surface == null)) {
        surface = _Surface(type, modal || popupRoot || dialog);
        surfaces.add(surface);
      }
      if (surface != null && _contentTypes.contains(type)) {
        types.update(type, (count) => count + 1, ifAbsent: () => 1);
        if (entrance) {
          surface.entrance++;
        } else if (allowNativePopups && surface.modal && native) {
          surface.native++;
        } else {
          surface.missing.update(type, (count) => count + 1, ifAbsent: () => 1);
        }
      }
    }
    final children = node['children'];
    if (children is List) {
      for (final child in children.whereType<Map>()) {
        walk(child, surface: surface, entrance: entrance, native: native);
      }
    }
  }

  bool report() {
    var missing = 0;
    var covered = 0;
    var native = 0;
    for (final surface in surfaces) {
      covered += surface.entrance;
      native += surface.native;
      missing += surface.missing.values.fold(0, (n, count) => n + count);
    }
    final screens = surfaces.where((s) => !s.modal).length;
    stdout.writeln(
      jsonEncode({
        'nodes': nodes,
        'screens': screens,
        'entranceGroups': groups,
        'offstageBranches': offstage,
        'contentTypes': types,
        'coveredByEntrance': covered,
        'coveredByNativePopup': native,
        'uncovered': missing,
        'surfaces': [
          for (final s in surfaces)
            {
              'type': s.type,
              'kind': s.modal ? 'modal' : 'screen',
              'coveredByEntrance': s.entrance,
              'coveredByNativePopup': s.native,
              'uncoveredTypes': s.missing,
            },
        ],
        'scope': _limit,
      }),
    );
    return nodes > 0 && screens > 0 && types.isNotEmpty && missing == 0;
  }
}

class _Failure implements Exception {
  const _Failure(this.message);
  final String message;
}

Future<Uri> _localService(String file) async {
  final input = (await File(file).readAsString()).trim();
  final value = input.startsWith('{')
      ? (jsonDecode(input) as Map)['uri']
      : input;
  final uri = value is String ? Uri.tryParse(value) : null;
  if (uri == null ||
      !{'http', 'https', 'ws', 'wss'}.contains(uri.scheme) ||
      !{'localhost', '127.0.0.1', '::1'}.contains(uri.host) ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw const _Failure(
      'Expected a loopback Flutter VM service URI or service-info JSON.',
    );
  }
  final path = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (path.isNotEmpty && path.last == 'ws') path.removeLast();
  return uri.replace(
    scheme: {'https', 'wss'}.contains(uri.scheme) ? 'https' : 'http',
    pathSegments: [...path, ''],
  );
}

Future<void> main(List<String> args) async {
  if (args.length == 1 && args.first == '--help') {
    stdout.writeln('$_usage\n$_limit');
    return;
  }
  if (args.isEmpty ||
      args.first.startsWith('--') ||
      args.length > 2 ||
      (args.length == 2 && args.last != '--allow-native-popups')) {
    stderr.writeln(_usage);
    exitCode = 64;
    return;
  }

  final client = HttpClient()..findProxy = (_) => 'DIRECT';
  try {
    final service = await _localService(args.first);
    Future<Map> rpc(
      String method, [
      Map<String, String> params = const {},
    ]) async {
      final req = await client.getUrl(
        service.resolve(method).replace(queryParameters: params),
      );
      req.followRedirects = false;
      final res = await req.close();
      if (res.statusCode != 200) {
        throw _Failure(
          'Local service rejected $method (HTTP ${res.statusCode}).',
        );
      }
      final response =
          jsonDecode(await res.transform(utf8.decoder).join()) as Map;
      if (response['result'] is! Map) {
        throw _Failure('Flutter VM service failed $method.');
      }
      return response['result'] as Map;
    }

    Future<Map> call(String method, [Map<String, String> params = const {}]) =>
        rpc(method, params).timeout(const Duration(seconds: 15));
    final vm = await call('getVM');
    final isolates = (vm['isolates'] as List).whereType<Map>().toList()
      ..sort(
        (a, b) => (b['name'] == 'main' ? 1 : 0) - (a['name'] == 'main' ? 1 : 0),
      );
    String? id;
    for (final ref in isolates) {
      final candidate = ref['id'] as String;
      final isolate = await call('getIsolate', {'isolateId': candidate});
      if ((isolate['extensionRPCs'] as List?)?.contains(_treeMethod) ?? false) {
        id = candidate;
        break;
      }
    }
    if (id == null) {
      throw const _Failure(
        'No Flutter isolate with the widget inspector was found.',
      );
    }
    final group =
        'asteria.motion.$pid.${DateTime.now().microsecondsSinceEpoch}';
    try {
      final tree = (await call(_treeMethod, {
        'isolateId': id,
        'groupName': group,
        'isSummaryTree': 'false',
        'withPreviews': 'false',
        'fullDetails': 'false',
      }))['result'];
      final snapshot = _Snapshot(args.contains('--allow-native-popups'));
      if (tree is Map) snapshot.walk(tree);
      if (!snapshot.report()) exitCode = 1;
    } finally {
      await call('ext.flutter.inspector.disposeGroup', {
        'isolateId': id,
        'objectGroup': group,
      });
    }
  } on _Failure catch (e) {
    stderr.writeln(e.message);
    exitCode = 2;
  } on TimeoutException {
    stderr.writeln('Timed out reading the local Flutter VM service.');
    exitCode = 2;
  } on SocketException {
    stderr.writeln(
      'Cannot connect to the local Flutter VM service. Check that the debug session is still running.',
    );
    exitCode = 2;
  } catch (_) {
    // Raw exceptions can include local file paths or the VM authentication token.
    stderr.writeln(
      'Cannot read the local service file or inspector response. Check the debug session and URI file.',
    );
    exitCode = 2;
  } finally {
    client.close(force: true);
  }
}
