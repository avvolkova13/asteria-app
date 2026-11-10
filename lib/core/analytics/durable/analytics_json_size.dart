import 'dart:convert';

/// Size used by Python json.dumps defaults on the server: ASCII escaping and
/// spaces after separators. Count UTF-16 units to include surrogate pairs.
int analyticsJsonSize(Object? value) {
  if (value is Map) {
    return 2 +
        (value.isEmpty ? 0 : (value.length - 1) * 2) +
        value.entries.fold<int>(
          0,
          (size, e) =>
              size + analyticsJsonSize(e.key) + 2 + analyticsJsonSize(e.value),
        );
  }
  if (value is List) {
    return 2 +
        (value.isEmpty ? 0 : (value.length - 1) * 2) +
        value.fold<int>(0, (size, e) => size + analyticsJsonSize(e));
  }
  return jsonEncode(
    value,
  ).codeUnits.fold<int>(0, (size, unit) => size + (unit >= 127 ? 6 : 1));
}
