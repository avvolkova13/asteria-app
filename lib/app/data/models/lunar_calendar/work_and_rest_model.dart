class WorkAndRestModel {
  final int status;
  final String jobChange;
  final String careerGrowth;
  final String work;
  final String travel;
  final String importantDecisions;

  const WorkAndRestModel({
    required this.status,
    required this.jobChange,
    required this.careerGrowth,
    required this.work,
    required this.travel,
    required this.importantDecisions,
  });

  factory WorkAndRestModel.fromJson(Map<String, dynamic> json) {
    return WorkAndRestModel(
      status: json['status'] as int,
      jobChange: json['job_change'] as String,
      careerGrowth: json['career_growth'] as String,
      work: json['work'] as String,
      travel: json['travel'] as String,
      importantDecisions: json['important_decisions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'job_change': jobChange,
      'career_growth': careerGrowth,
      'work': work,
      'travel': travel,
      'important_decisions': importantDecisions,
    };
  }

  WorkAndRestModel copyWith({
    int? status,
    String? jobChange,
    String? careerGrowth,
    String? work,
    String? travel,
    String? importantDecisions,
  }) {
    return WorkAndRestModel(
      status: status ?? this.status,
      jobChange: jobChange ?? this.jobChange,
      careerGrowth: careerGrowth ?? this.careerGrowth,
      work: work ?? this.work,
      travel: travel ?? this.travel,
      importantDecisions: importantDecisions ?? this.importantDecisions,
    );
  }
}
