part of 'user_model.dart';

class SolarDataModel {
  final String data;

  const SolarDataModel({required this.data});

  factory SolarDataModel.fromJson(Map<String, dynamic> json) {
    return SolarDataModel(data: json['data'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'data': data};
  }

  SolarDataModel copyWith({String? data}) {
    return SolarDataModel(data: data ?? this.data);
  }
}
