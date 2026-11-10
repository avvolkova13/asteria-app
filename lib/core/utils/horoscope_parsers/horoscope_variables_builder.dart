Map<String, String> buildHoroscopeVariables({
  required String name,
  required String birthDate,
  required String dateNow,
  String? birthTime,
  String? zodiac,
  String? dateTime,
  String? planetsBirthdate,
  String? planetsToday,
  String? data,
}) {
  final variables = <String, String>{
    'name': name,
    'birthdate': birthDate,
    'date_now': dateNow,
  };

  if (birthTime != null) variables['birthtime'] = birthTime;
  if (zodiac != null) variables['zodiac'] = zodiac;
  if (dateTime != null) variables['date_time'] = dateTime;
  if (planetsBirthdate != null) {
    variables['planets_birthdate'] = planetsBirthdate;
  }
  if (planetsToday != null) variables['planets_today'] = planetsToday;
  if (data != null) variables['data'] = data;

  return variables;
}

Map<String, String> buildNatalCardVariables({
  required String name,
  required String birthdate,
  required String birthtime,
  required String fire,
  required String earth,
  required String air,
  required String water,
  required String city,
  required String planetsBirthdate,
  String? calculationContext,
}) {
  final enrichedPlanetsBirthdate = [
    planetsBirthdate,
    if (calculationContext != null && calculationContext.trim().isNotEmpty)
      calculationContext.trim(),
  ].join('\n\n');

  return {
    'name': name,
    'birthdate': birthdate,
    'birthtime': birthtime,
    'fire': fire,
    'earth': earth,
    'air': air,
    'water': water,
    'city': city,
    'planets_birthdate': enrichedPlanetsBirthdate,
  };
}

String buildNatalCardInstructions(String language) {
  if (language == 'en') {
    return '''
You are a professional astrologer writing a premium natal chart interpretation for Asteria.

Use the calculated natal data from planets_birthdate as the astrological source material. The birth date, time, and city describe the person, but the calculated positions are the source for planet signs, houses, elements, house system, zodiac type, and longitudes.

Copy each object's exact sign and house from the calculated positions before interpreting it. Do not recalculate, infer, swap, or alter a sign or house when writing the answer.

If the birth date, city, or model memory conflicts with planets_birthdate, planets_birthdate wins. Parse the canonical list in the form "Object - Sign - House"; for example, "Sun - Capricorn - 3" means the sun interpretation must open with "Sun in Capricorn in the 3rd house...", not another house.

Write rich, specific, humane interpretations. Avoid generic filler. For planet_interpretations, interpret each listed object from its exact calculated placement. For house_interpretations, interpret the calculated strong, weak, and accent houses from planets_birthdate.

Keep the provided JSON schema exactly. Generated natural-language values must be in US English.
''';
  }

  return '''
Ты профессиональный астролог и пишешь премиальную интерпретацию натальной карты для Asteria.

Используй расчетные данные из planets_birthdate как астрологическую основу. Дата, время и город описывают пользователя, но знаки планет, дома, стихии, система домов, тип зодиака и долготы берутся из расчетного блока.

Перед интерпретацией каждого объекта копируй его точный знак и дом из расчетных позиций. Не пересчитывай, не выводи по памяти, не меняй и не переставляй знак или дом в ответе.

Если дата рождения, город или знания модели конфликтуют с planets_birthdate, приоритет всегда у planets_birthdate. Разбирай канонический список в формате "Объект - Знак - Дом"; например, "Солнце - Козерог - 3" означает, что интерпретация sun должна начинаться как "Солнце в Козероге в 3 доме...", а не с другим домом.

Пиши живые, конкретные, глубокие интерпретации без шаблонных общих фраз. В planet_interpretations трактуй каждый объект по его точному расчетному положению. В house_interpretations трактуй расчетные сильный, слабый и акцентный дома из planets_birthdate.

Сохраняй переданную JSON-схему без изменений. Все сгенерированные текстовые значения пиши на русском языке.
''';
}

Map<String, String> buildLoveDeckVariables({
  required String cardNameOne,
  required String cardPositionOne,
  required String cardNameTwo,
  required String cardPositionTwo,
  required String cardNameThree,
  required String cardPositionThree,
  required String cardNameFour,
  required String cardPositionFour,
  required String cardNameFive,
  required String cardPositionFive,
  required String cardNameSix,
  required String cardPositionSix,
}) {
  return {
    'card_name_one': cardNameOne,
    'card_position_one': cardPositionOne,
    'card_name_two': cardNameTwo,
    'card_position_two': cardPositionTwo,
    'card_name_three': cardNameThree,
    'card_position_three': cardPositionThree,
    'card_name_four': cardNameFour,
    'card_position_four': cardPositionFour,
    'card_name_five': cardNameFive,
    'card_position_five': cardPositionFive,
    'card_name_six': cardNameSix,
    'card_position_six': cardPositionSix,
  };
}

Map<String, String> buildTarotDeckLayoutVariables({
  required String firstCardName,
  required String firstCardMeaning,
  required String secondCardName,
  required String secondCardMeaning,
  required String thirdCardName,
  required String thirdCardMeaning,
}) {
  return {
    'first_card_name': firstCardName,
    'first_card_meaning': firstCardMeaning,
    'second_card_name': secondCardName,
    'second_card_meaning': secondCardMeaning,
    'third_card_name': thirdCardName,
    'third_card_meaning': thirdCardMeaning,
  };
}

Map<String, String> buildRuneDeckLayoutVariables({
  required String firstRuneName,
  required String firstRuneMeaning,
  required String secondRuneName,
  required String secondRuneMeaning,
  required String thirdRuneName,
  required String thirdRuneMeaning,
}) {
  return {
    'first_rune_name': firstRuneName,
    'first_rune_meaning': firstRuneMeaning,
    'second_rune_name': secondRuneName,
    'second_rune_meaning': secondRuneMeaning,
    'third_rune_name': thirdRuneName,
    'third_rune_meaning': thirdRuneMeaning,
  };
}

Map<String, String> buildKeltDeckVariables({
  required String cardNameOne,
  required String cardPositionOne,
  required String cardNameTwo,
  required String cardPositionTwo,
  required String cardNameThree,
  required String cardPositionThree,
  required String cardNameFour,
  required String cardPositionFour,
  required String cardNameFive,
  required String cardPositionFive,
  required String cardNameSix,
  required String cardPositionSix,
  required String cardNameSeven,
  required String cardPositionSeven,
  required String cardNameEight,
  required String cardPositionEight,
  required String cardNameNine,
  required String cardPositionNine,
  required String cardNameTen,
  required String cardPositionTen,
}) {
  return {
    'card_name_one': cardNameOne,
    'card_position_one': cardPositionOne,
    'card_name_two': cardNameTwo,
    'card_position_two': cardPositionTwo,
    'card_name_three': cardNameThree,
    'card_position_three': cardPositionThree,
    'card_name_four': cardNameFour,
    'card_position_four': cardPositionFour,
    'card_name_five': cardNameFive,
    'card_position_five': cardPositionFive,
    'card_name_six': cardNameSix,
    'card_position_six': cardPositionSix,
    'card_name_seven': cardNameSeven,
    'card_position_seven': cardPositionSeven,
    'card_name_eight': cardNameEight,
    'card_position_eight': cardPositionEight,
    'card_name_nine': cardNameNine,
    'card_position_nine': cardPositionNine,
    'card_name_ten': cardNameTen,
    'card_position_ten': cardPositionTen,
  };
}
