import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'notification_response.g.dart';

@JsonSerializable()
class NotificationResponse extends BaseResponse {
  final List<Notification> notifications;

  NotificationResponse(
      {required int status, required String message, required this.notifications})
      : super(status: status, message: message);

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}