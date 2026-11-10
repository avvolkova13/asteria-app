class BeautyModel {
  final int status;
  final String haircut;
  final String hairColoring;
  final String skinCare;
  final String manicurePedicure;
  final String cosmetology;
  final String epilationDepilation;
  final String spaAndRelaxation;
  final String fragrancesAndMagnetism;

  const BeautyModel({
    required this.status,
    required this.haircut,
    required this.hairColoring,
    required this.skinCare,
    required this.manicurePedicure,
    required this.cosmetology,
    required this.epilationDepilation,
    required this.spaAndRelaxation,
    required this.fragrancesAndMagnetism,
  });

  factory BeautyModel.fromJson(Map<String, dynamic> json) {
    return BeautyModel(
      status: json['status'] as int,
      haircut: json['haircut'] as String,
      hairColoring: json['hair_coloring'] as String,
      skinCare: json['skin_care'] as String,
      manicurePedicure: json['manicure_pedicure'] as String,
      cosmetology: json['cosmetology'] as String,
      epilationDepilation: json['epilation_depilation'] as String,
      spaAndRelaxation: json['spa_and_relaxation'] as String,
      fragrancesAndMagnetism: json['fragrances_and_magnetism'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'haircut': haircut,
      'hair_coloring': hairColoring,
      'skin_care': skinCare,
      'manicure_pedicure': manicurePedicure,
      'cosmetology': cosmetology,
      'epilation_depilation': epilationDepilation,
      'spa_and_relaxation': spaAndRelaxation,
      'fragrances_and_magnetism': fragrancesAndMagnetism,
    };
  }

  BeautyModel copyWith({
    int? status,
    String? haircut,
    String? hairColoring,
    String? skinCare,
    String? manicurePedicure,
    String? cosmetology,
    String? epilationDepilation,
    String? spaAndRelaxation,
    String? fragrancesAndMagnetism,
  }) {
    return BeautyModel(
      status: status ?? this.status,
      haircut: haircut ?? this.haircut,
      hairColoring: hairColoring ?? this.hairColoring,
      skinCare: skinCare ?? this.skinCare,
      manicurePedicure: manicurePedicure ?? this.manicurePedicure,
      cosmetology: cosmetology ?? this.cosmetology,
      epilationDepilation: epilationDepilation ?? this.epilationDepilation,
      spaAndRelaxation: spaAndRelaxation ?? this.spaAndRelaxation,
      fragrancesAndMagnetism:
          fragrancesAndMagnetism ?? this.fragrancesAndMagnetism,
    );
  }
}
