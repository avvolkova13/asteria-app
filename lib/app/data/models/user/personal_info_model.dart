part of 'user_model.dart';

class PersonalInfoModel {
  final BirthPlaceModel? birthPlace;
  final BirthDateModel? birthDate;
  final Gender? gender;

  const PersonalInfoModel({this.birthPlace, this.birthDate, this.gender});

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      birthPlace: json['birth_place'] != null ? BirthPlaceModel.fromJson(json['birth_place'] as Map<String, dynamic>) : null,
      birthDate: json['birth_date'] != null ? BirthDateModel.fromJson(json['birth_date'] as Map<String, dynamic>) : null,
      gender: json['gender'] != null
          ? Gender.values.firstWhere((e) => e.name == json['gender'], orElse: () => Gender.male)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'birth_place': birthPlace?.toJson(), 'birth_date': birthDate?.toJson(), 'gender': gender?.name};
  }

  PersonalInfoModel copyWith({BirthPlaceModel? birthPlace, BirthDateModel? birthDate, Gender? gender}) {
    return PersonalInfoModel(
      birthPlace: birthPlace ?? this.birthPlace,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
    );
  }
}
