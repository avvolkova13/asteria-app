import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_period.dart';

DateTime calculateDateUntil(HoroscopePeriod period) {
  final now = DateTime.now();
  switch (period) {
    case HoroscopePeriod.day:
      return now.add(const Duration(days: 1));
    case HoroscopePeriod.week:
      return now.add(const Duration(days: 7));
    case HoroscopePeriod.month:
      final month = now.month + 1;
      final year = month > 12 ? now.year + 1 : now.year;
      final finalMonth = month > 12 ? month - 12 : month;
      return DateTime(year, finalMonth, now.day);
    case HoroscopePeriod.year:
      return DateTime(now.year + 1, now.month, now.day);
  }
}

Map<String, dynamic> sanitizeArea(dynamic area) {
  if (area == null || area is! Map) {
    return {'key_theme': '', 'theme_title': '', 'description': ''};
  }
  final areaMap = Map<String, dynamic>.from(area);
  return {
    'key_theme': areaMap['key_theme'] ?? '',
    'theme_title': areaMap['theme_title'] ?? '',
    'description': areaMap['description'] ?? '',
  };
}

List<Map<String, dynamic>> sanitizeWeakPoints(dynamic weakPoints) {
  if (weakPoints == null || weakPoints is! List) {
    return [];
  }
  return weakPoints.map((e) {
    if (e is Map) {
      final weakPointMap = Map<String, dynamic>.from(e);
      return {'title': weakPointMap['title'] ?? '', 'description': weakPointMap['description'] ?? ''};
    }
    return {'title': '', 'description': ''};
  }).toList();
}

String sanitizePercentage(dynamic percentage) {
  return percentage?.toString() ?? '';
}

String sanitizeString(dynamic value) {
  return value?.toString() ?? '';
}

bool sanitizeBool(dynamic value, {bool defaultValue = false}) {
  return value is bool ? value : defaultValue;
}

List<String> sanitizeListOfStrings(dynamic list) {
  if (list == null || list is! List) {
    return [];
  }
  return list.map((e) => e?.toString() ?? '').toList();
}

Map<String, dynamic> sanitizePeriod(dynamic period) {
  if (period == null || period is! Map) {
    return {'dates': '', 'text': ''};
  }
  final periodMap = Map<String, dynamic>.from(period);
  return {'dates': (periodMap['dates'] as String?) ?? '', 'text': (periodMap['text'] as String?) ?? ''};
}

Map<String, dynamic> sanitizePlanetInSign(dynamic planetInSign) {
  if (planetInSign == null || planetInSign is! Map) {
    return {'planet_in_sign': '', 'description': ''};
  }
  final planetMap = Map<String, dynamic>.from(planetInSign);
  return {'planet_in_sign': planetMap['planet_in_sign'] ?? '', 'description': planetMap['description'] ?? ''};
}

Map<String, dynamic> sanitizeCoreDescription(dynamic coreDescription) {
  if (coreDescription == null || coreDescription is! Map) {
    return {
      'sun_in_sign': {'planet_in_sign': '', 'description': ''},
      'moon_in_sign': {'planet_in_sign': '', 'description': ''},
      'ascendant_in_sign': {'planet_in_sign': '', 'description': ''},
    };
  }
  final coreMap = Map<String, dynamic>.from(coreDescription);
  return {
    'sun_in_sign': sanitizePlanetInSign(coreMap['sun_in_sign']),
    'moon_in_sign': sanitizePlanetInSign(coreMap['moon_in_sign']),
    'ascendant_in_sign': sanitizePlanetInSign(coreMap['ascendant_in_sign']),
  };
}

Map<String, dynamic> sanitizeLoveSection(dynamic love) {
  if (love == null || love is! Map) {
    return {'general': '', 'lesson': '', 'compatibility': []};
  }
  final loveMap = Map<String, dynamic>.from(love);
  return {
    'general': loveMap['general'] ?? '',
    'lesson': loveMap['lesson'] ?? '',
    'compatibility': sanitizeListOfStrings(loveMap['compatibility']),
  };
}

Map<String, dynamic> sanitizeWorkSection(dynamic work) {
  if (work == null || work is! Map) {
    return {'general': '', 'important': '', 'success_examples': []};
  }
  final workMap = Map<String, dynamic>.from(work);
  return {
    'general': workMap['general'] ?? '',
    'important': workMap['important'] ?? '',
    'success_examples': sanitizeListOfStrings(workMap['success_examples']),
  };
}

Map<String, dynamic> sanitizeFinanceSection(dynamic finance) {
  if (finance == null || finance is! Map) {
    return {'general': '', 'risk': '', 'advice': ''};
  }
  final financeMap = Map<String, dynamic>.from(finance);
  return {'general': financeMap['general'] ?? '', 'risk': financeMap['risk'] ?? '', 'advice': financeMap['advice'] ?? ''};
}

Map<String, dynamic> sanitizeTransit(dynamic transit) {
  if (transit == null || transit is! Map) {
    return {'planet': '', 'description': ''};
  }
  final transitMap = Map<String, dynamic>.from(transit);
  return {'planet': transitMap['planet'] ?? '', 'description': transitMap['description'] ?? ''};
}

Map<String, dynamic> sanitizeTransformationSection(dynamic transformation) {
  if (transformation == null || transformation is! Map) {
    return {'general': '', 'transits': []};
  }
  final transformationMap = Map<String, dynamic>.from(transformation);
  final transits = transformationMap['transits'];
  return {
    'general': transformationMap['general'] ?? '',
    'transits': transits is List ? transits.map((e) => sanitizeTransit(e)).toList() : [],
  };
}

Map<String, dynamic> sanitizeDayHoroscopeJson(Map<String, dynamic> json) {
  final sanitized = Map<String, dynamic>.from(json);

  sanitized['date_until'] = calculateDateUntil(HoroscopePeriod.day).toIso8601String();
  sanitized['is_key_theme_opened'] = true;
  sanitized['is_weakness_opened'] = true;
  sanitized['focus'] = sanitizeString(sanitized['focus']);
  sanitized['risk'] = sanitizeString(sanitized['risk']);

  sanitized['personal_area'] = sanitizeArea(sanitized['personal_area']);
  sanitized['personal_weak_points'] = sanitizeWeakPoints(sanitized['personal_weak_points']);
  sanitized['personal_area_persentage'] = sanitizePercentage(sanitized['personal_area_persentage']);

  sanitized['love_area'] = sanitizeArea(sanitized['love_area']);
  sanitized['love_weak_points'] = sanitizeWeakPoints(sanitized['love_weak_points']);
  sanitized['love_area_persentage'] = sanitizePercentage(sanitized['love_area_persentage']);

  sanitized['finance_area'] = sanitizeArea(sanitized['finance_area']);
  sanitized['finance_weak_points'] = sanitizeWeakPoints(sanitized['finance_weak_points']);
  sanitized['finance_area_persentage'] = sanitizePercentage(sanitized['finance_area_persentage']);

  sanitized['spotlight'] = sanitizeString(sanitized['spotlight']);

  return sanitized;
}


Map<String, dynamic> sanitizeWeekHoroscopeJson(Map<String, dynamic> json) {
  final sanitized = Map<String, dynamic>.from(json);

  sanitized['date_until'] = calculateDateUntil(HoroscopePeriod.week).toIso8601String();
  sanitized['personal_area'] = sanitizeArea(sanitized['personal_area']);
  sanitized['personal_area_persentage'] = sanitizePercentage(sanitized['personal_area_persentage']);
  sanitized['love_area'] = sanitizeArea(sanitized['love_area']);
  sanitized['love_area_persentage'] = sanitizePercentage(sanitized['love_area_persentage']);
  sanitized['finance_area'] = sanitizeArea(sanitized['finance_area']);
  sanitized['finance_area_persentage'] = sanitizePercentage(sanitized['finance_area_persentage']);
  sanitized['advice'] = sanitizeString(sanitized['advice']);

  return sanitized;
}

Map<String, dynamic> sanitizeMonthHoroscopeJson(Map<String, dynamic> json) {
  final sanitized = Map<String, dynamic>.from(json);

  sanitized['date_until'] = calculateDateUntil(HoroscopePeriod.month).toIso8601String();

  sanitized['personal_area'] = sanitizeArea(sanitized['personal_area']);
  sanitized['personal_area_persentage'] = sanitizePercentage(sanitized['personal_area_persentage']);

  sanitized['love_area'] = sanitizeArea(sanitized['love_area']);
  sanitized['love_area_persentage'] = sanitizePercentage(sanitized['love_area_persentage']);

  sanitized['finance_area'] = sanitizeArea(sanitized['finance_area']);
  sanitized['finance_area_persentage'] = sanitizePercentage(sanitized['finance_area_persentage']);

  final periods = sanitized['periods'];
  if (periods == null || periods is! Map) {
    sanitized['periods'] = {
      'best_days_for_work': {'dates': '', 'text': ''},
      'best_days_for_self_focus': {'dates': '', 'text': ''},
      'best_days_for_relationships': {'dates': '', 'text': ''},
    };
  } else {
    final periodsMap = Map<String, dynamic>.from(periods);
    sanitized['periods'] = {
      'best_days_for_work': sanitizePeriod(periodsMap['best_days_for_work']),
      'best_days_for_self_focus': sanitizePeriod(periodsMap['best_days_for_self_focus']),
      'best_days_for_relationships': sanitizePeriod(periodsMap['best_days_for_relationships']),
    };
  }

  sanitized['key_topic'] = sanitizeString(sanitized['key_topic']);
  sanitized['advice'] = sanitizeString(sanitized['advice']);

  return sanitized;
}

Map<String, dynamic> sanitizeYearHoroscopeJson(Map<String, dynamic> json) {
  final sanitized = Map<String, dynamic>.from(json);

  sanitized['date_until'] = calculateDateUntil(HoroscopePeriod.year).toIso8601String();
  sanitized['core_description'] = sanitizeCoreDescription(sanitized['core_description']);
  sanitized['emotional_world'] = sanitizeString(sanitized['emotional_world']);
  sanitized['weak_points'] = sanitizeWeakPoints(sanitized['weak_points']);
  sanitized['recommendations'] = sanitizeListOfStrings(sanitized['recommendations']);
  sanitized['astro_metaphor'] = sanitizeString(sanitized['astro_metaphor']);
  sanitized['love'] = sanitizeLoveSection(sanitized['love']);
  sanitized['work'] = sanitizeWorkSection(sanitized['work']);
  sanitized['finance'] = sanitizeFinanceSection(sanitized['finance']);
  sanitized['transformation'] = sanitizeTransformationSection(sanitized['transformation']);

  return sanitized;
}
