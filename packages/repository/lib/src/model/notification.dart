import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification{
  final String message;
  final String data;
  final DateTime createdAt;

  Notification({required this.message,required this.data,required this.createdAt,
  });


  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}