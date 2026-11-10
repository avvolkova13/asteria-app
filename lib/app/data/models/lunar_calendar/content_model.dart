import 'package:asteria_app/app/data/models/lunar_calendar/beauty_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/gardening_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/health_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/work_and_rest_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/relationships_model.dart';

class ContentModel {
  final BeautyModel beauty;
  final GardeningModel gardening;
  final HealthModel health;
  final WorkAndRestModel workAndRest;
  final RelationshipsModel relationships;

  const ContentModel({
    required this.beauty,
    required this.gardening,
    required this.health,
    required this.workAndRest,
    required this.relationships,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      beauty: BeautyModel.fromJson(
        Map<String, dynamic>.from(json['beauty'] as Map),
      ),
      gardening: GardeningModel.fromJson(
        Map<String, dynamic>.from(json['gardening'] as Map),
      ),
      health: HealthModel.fromJson(
        Map<String, dynamic>.from(json['health'] as Map),
      ),
      workAndRest: WorkAndRestModel.fromJson(
        Map<String, dynamic>.from(json['work_and_rest'] as Map),
      ),
      relationships: RelationshipsModel.fromJson(
        Map<String, dynamic>.from(json['relationships'] as Map),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beauty': beauty.toJson(),
      'gardening': gardening.toJson(),
      'health': health.toJson(),
      'work_and_rest': workAndRest.toJson(),
      'relationships': relationships.toJson(),
    };
  }

  ContentModel copyWith({
    BeautyModel? beauty,
    GardeningModel? gardening,
    HealthModel? health,
    WorkAndRestModel? workAndRest,
    RelationshipsModel? relationships,
  }) {
    return ContentModel(
      beauty: beauty ?? this.beauty,
      gardening: gardening ?? this.gardening,
      health: health ?? this.health,
      workAndRest: workAndRest ?? this.workAndRest,
      relationships: relationships ?? this.relationships,
    );
  }

  int get categoryStatus => beauty.status + gardening.status + health.status + workAndRest.status + relationships.status;
}
