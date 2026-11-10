enum PhaseTone {
  reset,
  growth,
  action,
  refinement,
  intensity,
  integration,
  release,
  recovery,
}

enum RecommendationStatus { favorable, neutral, unfavorable }

PhaseTone parsePhaseTone(Object? value) {
  return PhaseTone.values.firstWhere(
    (tone) => tone.name == value,
    orElse: () => throw FormatException('Unknown phase tone: $value'),
  );
}

RecommendationStatus parseRecommendationStatus(Object? value) {
  return RecommendationStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () =>
        throw FormatException('Unknown recommendation status: $value'),
  );
}

class DailyBackgroundModel {
  final PhaseTone tone;
  final String title;
  final String summary;

  const DailyBackgroundModel({
    required this.tone,
    required this.title,
    required this.summary,
  });

  factory DailyBackgroundModel.fromJson(Map<String, dynamic> json) {
    return DailyBackgroundModel(
      tone: parsePhaseTone(json['tone']),
      title: json['title'] as String,
      summary: json['summary'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'tone': tone.name, 'title': title, 'summary': summary};
  }
}

class TaskRecommendationModel {
  final RecommendationStatus status;
  final String description;

  const TaskRecommendationModel({
    required this.status,
    required this.description,
  });

  factory TaskRecommendationModel.fromJson(Map<String, dynamic> json) {
    return TaskRecommendationModel(
      status: parseRecommendationStatus(json['status']),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status.name, 'description': description};
  }
}

class SphereRecommendationModel {
  final RecommendationStatus status;
  final Map<String, TaskRecommendationModel> tasks;

  const SphereRecommendationModel({required this.status, required this.tasks});

  factory SphereRecommendationModel.fromJson(Map<String, dynamic> json) {
    final rawTasks = Map<String, dynamic>.from(json['tasks'] as Map);
    return SphereRecommendationModel(
      status: parseRecommendationStatus(json['status']),
      tasks: rawTasks.map(
        (key, value) => MapEntry(
          key,
          TaskRecommendationModel.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'tasks': tasks.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class LunarDayRecommendationsModel {
  final DailyBackgroundModel dailyBackground;
  final Map<String, SphereRecommendationModel> spheres;

  const LunarDayRecommendationsModel({
    required this.dailyBackground,
    required this.spheres,
  });

  factory LunarDayRecommendationsModel.fromJson(Map<String, dynamic> json) {
    final rawSpheres = Map<String, dynamic>.from(json['spheres'] as Map);
    return LunarDayRecommendationsModel(
      dailyBackground: DailyBackgroundModel.fromJson(
        Map<String, dynamic>.from(json['daily_background'] as Map),
      ),
      spheres: rawSpheres.map(
        (key, value) => MapEntry(
          key,
          SphereRecommendationModel.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_background': dailyBackground.toJson(),
      'spheres': spheres.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}
