part of 'user_model.dart';

class BirthPlaceModel {
  final String location;
  final double latitude;
  final double longitude;

  const BirthPlaceModel({required this.location, required this.latitude, required this.longitude});

  factory BirthPlaceModel.fromJson(Map<String, dynamic> json) {
    return BirthPlaceModel(
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'location': location, 'latitude': latitude, 'longitude': longitude};
  }

  BirthPlaceModel copyWith({String? location, double? latitude, double? longitude}) {
    return BirthPlaceModel(
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
