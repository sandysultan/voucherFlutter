import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'kiosk.g.dart';

@JsonSerializable()
class Kiosk {
  final String kioskName;
  final int id;
  final double? latitude;
  final double? longitude;
  final bool? photo;
  final bool status;
  final String? founder;
  final String? whatsapp;
  final double kioskShare;
  final int powerCost;
  final DateTime createdAt;
  final List<Sales>? sales;

  Kiosk({
    required this.kioskName,
    required this.id,
    this.latitude,
    this.longitude,
    this.photo,
    required this.status,
    this.founder,
    this.whatsapp,
    required this.kioskShare,
    this.sales,
    required this.powerCost,
    required this.createdAt,
  });

  factory Kiosk.fromJson(Map<String, dynamic> json) => _$KioskFromJson(json);
  Map<String, dynamic> toJson() => _$KioskToJson(this);

  Kiosk copy({
    String? kioskName,
    int? id,
    double? latitude,
    double? longitude,
    bool? photo,
    bool? status,
    String? founder,
    String? whatsapp,
    double? kioskShare,
    int? powerCost,
    DateTime? createdAt,
    List<Sales>? sales,
  }) {
    return Kiosk(
      kioskName: kioskName ?? this.kioskName,
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photo: photo ?? this.photo,
      status: status ?? this.status,
      founder: founder ?? this.founder,
      whatsapp: whatsapp ?? this.whatsapp,
      kioskShare: kioskShare ?? this.kioskShare,
      powerCost: powerCost ?? this.powerCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
