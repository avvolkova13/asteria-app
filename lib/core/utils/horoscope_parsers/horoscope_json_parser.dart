import 'dart:convert';

Map<String, dynamic> parseHoroscopeJson(String rawText) {
  final cleaned = extractJsonPayload(rawText);
  final dynamic decoded = jsonDecode(cleaned);
  
  if (decoded is Map<String, dynamic>) {
    if (decoded.containsKey('text') && decoded['text'] is String) {
      final textValue = decoded['text'] as String;
      final textDecoded = jsonDecode(textValue);
      if (textDecoded is Map<String, dynamic>) {
        return textDecoded;
      }
    }
    return decoded;
  }
  
  throw Exception('Некорректный формат JSON для гороскопа');
}

String extractJsonPayload(String rawText) {
  final trimmed = rawText.trim();
  if (trimmed.startsWith('```')) {
    final firstLineBreak = trimmed.indexOf('\n');
    final lastFenceIndex = trimmed.lastIndexOf('```');
    if (firstLineBreak != -1 && lastFenceIndex != -1 && lastFenceIndex > firstLineBreak) {
      return trimmed.substring(firstLineBreak + 1, lastFenceIndex).trim();
    }
  }
  return trimmed;
}
