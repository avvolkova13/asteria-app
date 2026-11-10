import 'dart:convert';

/// Ответ от OpenAI API с промптом
class PromptResponse {
  final String id;
  final String object;
  final int createdAt;
  final String status;
  final List<Output> output;

  const PromptResponse({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.status,
    required this.output,
  });

  factory PromptResponse.fromJson(Map<String, dynamic> json) {
    return PromptResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      status: json['status'] as String,

      output: (json['output'] as List).map((e) => Output.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created_at': createdAt,
      'status': status,
      'output': output.map((e) => e.toJson()).toList(),
    };
  }

  /// Извлекает текст из output[0].content[0].text
  String? get responseText {
    if (output.isEmpty) return null;
    final firstOutput = output.first;
    if (firstOutput.content.isEmpty) return null;
    final firstContent = firstOutput.content.first;
    return firstContent.text;
  }

  /// Парсит JSON из responseText и извлекает данные совместимости
  CompatibilityData? get compatibilityData {
    final text = responseText;
    if (text == null) return null;

    try {
      final Map<String, dynamic> jsonData = jsonDecode(
        _extractJsonObject(text),
      );
      return CompatibilityData.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  String _extractJsonObject(String text) {
    final trimmedText = text.trim();
    final codeBlockMatch = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
      caseSensitive: false,
    ).firstMatch(trimmedText);
    final jsonText = codeBlockMatch?.group(1)?.trim() ?? trimmedText;

    final jsonStart = jsonText.indexOf('{');
    final jsonEnd = jsonText.lastIndexOf('}');
    if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
      return jsonText;
    }

    return jsonText.substring(jsonStart, jsonEnd + 1);
  }
}

/// Контент
class Content {
  final String type;
  final String text;
  final List<dynamic>? annotations;
  final List<dynamic>? logprobs;

  const Content({
    required this.type,
    required this.text,
    this.annotations,
    this.logprobs,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      type: json['type'] as String,
      text: json['text'] as String,
      annotations: json['annotations'] as List<dynamic>?,
      logprobs: json['logprobs'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'annotations': annotations,
      'logprobs': logprobs,
    };
  }
}

/// Вывод
class Output {
  final String id;
  final String type;
  final String status;
  final List<Content> content;
  final String role;

  const Output({
    required this.id,
    required this.type,
    required this.status,
    required this.content,
    required this.role,
  });

  factory Output.fromJson(Map<String, dynamic> json) {
    return Output(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      content: (json['content'] as List)
          .map((e) => Content.fromJson(e))
          .toList(),
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'content': content.map((e) => e.toJson()).toList(),
      'role': role,
    };
  }
}

/// Данные о совместимости
class CompatibilityData {
  final String generalCompatibility;
  final String loveCompatibility;
  final String loveCompatibilityPercentage;
  final String familyCompatibility;
  final String familyCompatibilityPercentage;
  final String conflicts;
  final String conflictsPercentage;
  final String percentage;
  final String phrase;
  final String introduction;

  const CompatibilityData({
    required this.generalCompatibility,
    required this.loveCompatibility,
    required this.loveCompatibilityPercentage,
    required this.familyCompatibility,
    required this.familyCompatibilityPercentage,
    required this.conflicts,
    required this.conflictsPercentage,
    required this.percentage,
    required this.phrase,
    required this.introduction,
  });

  factory CompatibilityData.fromJson(Map<String, dynamic> json) {
    return CompatibilityData(
      phrase: _readString(json, 'phrase'),
      introduction: _readString(json, 'introduction'),
      percentage: _readString(json, 'percentage'),
      generalCompatibility: _readString(json, 'general_compatibility'),
      loveCompatibility: _readString(json, 'love_compatibility'),
      loveCompatibilityPercentage: _readString(
        json,
        'love_compatibility_persentage',
        fallbackKey: 'love_compatibility_percentage',
      ),
      familyCompatibility: _readString(json, 'family_compatibility'),
      familyCompatibilityPercentage: _readString(
        json,
        'family_compatibility_persentage',
        fallbackKey: 'family_compatibility_percentage',
      ),
      conflicts: _readString(json, 'conflicts'),
      conflictsPercentage: _readString(
        json,
        'conflicts_persentage',
        fallbackKey: 'conflicts_percentage',
      ),
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    String key, {
    String? fallbackKey,
  }) {
    final value = json[key] ?? (fallbackKey == null ? null : json[fallbackKey]);
    return value?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'phrase': phrase,
      'introduction': introduction,
      'percentage': percentage,
      'general_compatibility': generalCompatibility,
      'love_compatibility': loveCompatibility,
      'love_compatibility_persentage': loveCompatibilityPercentage,
      'family_compatibility': familyCompatibility,
      'family_compatibility_persentage': familyCompatibilityPercentage,
      'conflicts': conflicts,
      'conflicts_persentage': conflictsPercentage,
    };
  }
}
