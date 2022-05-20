import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'kiosk_update_response.g.dart';

@JsonSerializable()
class KioskUpdateResponse extends BaseResponse {
  final Kiosk kiosk;

  KioskUpdateResponse(
      {required int status, required String message, required this.kiosk})
      : super(status: status, message: message);

  factory KioskUpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$KioskUpdateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$KioskUpdateResponseToJson(this);
}