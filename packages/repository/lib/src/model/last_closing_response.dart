import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'last_closing_response.g.dart';

@JsonSerializable()
class LastClosingResponse extends BaseResponse {
  final Closing? closing;

  LastClosingResponse(
      {required int status,
      required String message,
      this.closing,})
      : super(status: status, message: message);

  factory LastClosingResponse.fromJson(Map<String, dynamic> json) =>
      _$LastClosingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LastClosingResponseToJson(this);
}
