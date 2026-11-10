import 'generated/l10n.dart';
import 'package:intl/intl.dart';

extension LocalizedDisplayNames on AppLocalizations {
  String planetName(String code) => switch (code) {
    'sun' => planetSun,
    'moon' => planetMoon,
    'mercury' => planetMercury,
    'venus' => planetVenus,
    'mars' => planetMars,
    'jupiter' => planetJupiter,
    'saturn' => planetSaturn,
    'uranus' => planetUranus,
    'neptune' => planetNeptune,
    'pluto' => planetPluto,
    'chiron' => planetChiron,
    'lilith' => planetLilith,
    'selena' => planetSelena,
    'north_node' => planetNorthNode,
    'south_node' => planetSouthNode,
    'pars_fortunae' => planetParsFortunae,
    'vertex' => planetVertex,
    _ => code,
  };

  String zodiacSignName(String code) {
    final isRu = Intl.getCurrentLocale().startsWith('ru');
    return switch (code) {
      'aries' => isRu ? 'Овен' : 'Aries',
      'taurus' => isRu ? 'Телец' : 'Taurus',
      'gemini' => isRu ? 'Близнецы' : 'Gemini',
      'cancer' => isRu ? 'Рак' : 'Cancer',
      'leo' => isRu ? 'Лев' : 'Leo',
      'virgo' => isRu ? 'Дева' : 'Virgo',
      'libra' => isRu ? 'Весы' : 'Libra',
      'scorpio' => isRu ? 'Скорпион' : 'Scorpio',
      'sagittarius' => isRu ? 'Стрелец' : 'Sagittarius',
      'capricorn' => isRu ? 'Козерог' : 'Capricorn',
      'aquarius' => isRu ? 'Водолей' : 'Aquarius',
      'pisces' => isRu ? 'Рыбы' : 'Pisces',
      _ => code,
    };
  }
}
