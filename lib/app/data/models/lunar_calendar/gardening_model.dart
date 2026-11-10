class GardeningModel {
  final int status;
  final String sowingAndPlanting;
  final String transplantingAndPricking;
  final String wateringAndFertilizing;
  final String pestControl;
  final String harvestingAndPreserving;
  final String houseplants;
  final String garden;

  const GardeningModel({
    required this.status,
    required this.sowingAndPlanting,
    required this.transplantingAndPricking,
    required this.wateringAndFertilizing,
    required this.pestControl,
    required this.harvestingAndPreserving,
    required this.houseplants,
    required this.garden,
  });

  factory GardeningModel.fromJson(Map<String, dynamic> json) {
    return GardeningModel(
      status: json['status'] as int,
      sowingAndPlanting: json['sowing_and_planting'] as String,
      transplantingAndPricking: json['transplanting_and_pricking'] as String,
      wateringAndFertilizing: json['watering_and_fertilizing'] as String,
      pestControl: json['pest_control'] as String,
      harvestingAndPreserving: json['harvesting_and_preserving'] as String,
      houseplants: json['houseplants'] as String,
      garden: json['garden'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'sowing_and_planting': sowingAndPlanting,
      'transplanting_and_pricking': transplantingAndPricking,
      'watering_and_fertilizing': wateringAndFertilizing,
      'pest_control': pestControl,
      'harvesting_and_preserving': harvestingAndPreserving,
      'houseplants': houseplants,
      'garden': garden,
    };
  }

  GardeningModel copyWith({
    int? status,
    String? sowingAndPlanting,
    String? transplantingAndPricking,
    String? wateringAndFertilizing,
    String? pestControl,
    String? harvestingAndPreserving,
    String? houseplants,
    String? garden,
  }) {
    return GardeningModel(
      status: status ?? this.status,
      sowingAndPlanting: sowingAndPlanting ?? this.sowingAndPlanting,
      transplantingAndPricking:
          transplantingAndPricking ?? this.transplantingAndPricking,
      wateringAndFertilizing:
          wateringAndFertilizing ?? this.wateringAndFertilizing,
      pestControl: pestControl ?? this.pestControl,
      harvestingAndPreserving:
          harvestingAndPreserving ?? this.harvestingAndPreserving,
      houseplants: houseplants ?? this.houseplants,
      garden: garden ?? this.garden,
    );
  }
}
