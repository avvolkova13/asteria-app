String formatAiTemporalContext(
  DateTime localDateTime, {
  required Duration utcOffset,
}) {
  final offsetSign = utcOffset.isNegative ? '-' : '+';
  final absoluteOffset = utcOffset.abs();
  final offsetHours = absoluteOffset.inHours.toString().padLeft(2, '0');
  final offsetMinutes = (absoluteOffset.inMinutes % 60).toString().padLeft(
    2,
    '0',
  );
  final year = localDateTime.year.toString().padLeft(4, '0');
  final month = localDateTime.month.toString().padLeft(2, '0');
  final day = localDateTime.day.toString().padLeft(2, '0');
  final hour = localDateTime.hour.toString().padLeft(2, '0');
  final minute = localDateTime.minute.toString().padLeft(2, '0');

  return '$year-$month-$day $hour:$minute '
      '(UTC$offsetSign$offsetHours:$offsetMinutes)';
}

String buildAiTemporalGrounding(
  DateTime localDateTime, {
  String language = 'ru',
}) {
  final formattedDateTime = formatAiTemporalContext(
    localDateTime,
    utcOffset: localDateTime.timeZoneOffset,
  );

  if (language == 'en') {
    return '''
The user's current local date and time is $formattedDateTime. Treat this temporal context as the authoritative source of truth.
Interpret “today”, “tomorrow”, “nearest”, “next”, and other relative dates from this date. Never name a date that has already passed when the user asks for the next or nearest date. Always include the year in calendar recommendations.
The model's internal knowledge and previous answers are not proof of an exact astronomical or astrological date. Name a specific date only when it is explicitly provided in the input or returned by an available tool during the current request. Otherwise, do not estimate a date and say directly that an exact calculation is unavailable from the supplied data.''';
  }

  return '''
Текущая локальная дата и время пользователя: $formattedDateTime. Считай этот временной контекст достоверным источником истины.
Слова «сегодня», «завтра», «ближайший», «следующий» и другие относительные даты трактуй относительно этой даты. Если пользователь просит следующую или ближайшую дату, не называй уже прошедшую дату. В календарных рекомендациях всегда указывай год явно.
Внутренние знания модели и предыдущие ответы не считаются подтверждением точной астрономической или астрологической даты. Называй конкретную дату только тогда, когда она явно передана во входных данных или получена от доступного инструмента в текущем запросе. В остальных случаях не называй дату даже приблизительно и прямо сообщи, что точный расчёт по имеющимся данным недоступен.''';
}
