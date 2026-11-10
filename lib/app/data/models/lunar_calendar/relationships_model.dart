class RelationshipsModel {
  final int status;
  final String family;
  final String couple;
  final String friends;
  final String sex;
  final String forThoseAlone;

  const RelationshipsModel({
    required this.status,
    required this.family,
    required this.couple,
    required this.friends,
    required this.sex,
    required this.forThoseAlone,
  });

  factory RelationshipsModel.fromJson(Map<String, dynamic> json) {
    return RelationshipsModel(
      status: json['status'] as int,
      family: json['family'] as String,
      couple: json['couple'] as String,
      friends: json['friends'] as String,
      sex: json['sex'] as String,
      forThoseAlone: json['for_those_alone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'family': family,
      'couple': couple,
      'friends': friends,
      'sex': sex,
      'for_those_alone': forThoseAlone,
    };
  }

  RelationshipsModel copyWith({
    int? status,
    String? family,
    String? couple,
    String? friends,
    String? sex,
    String? forThoseAlone,
  }) {
    return RelationshipsModel(
      status: status ?? this.status,
      family: family ?? this.family,
      couple: couple ?? this.couple,
      friends: friends ?? this.friends,
      sex: sex ?? this.sex,
      forThoseAlone: forThoseAlone ?? this.forThoseAlone,
    );
  }
}
