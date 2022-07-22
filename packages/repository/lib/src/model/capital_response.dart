import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'capital_response.g.dart';

@JsonSerializable()
class CapitalResponse extends BaseResponse {
  final List<Capital> capitals;

  CapitalResponse(
      {required int status, required String message,required this.capitals,})
      : super(status: status, message: message);

  factory CapitalResponse.fromJson(Map<String, dynamic> json) =>
      _$CapitalResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CapitalResponseToJson(this);
}
