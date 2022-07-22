import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'add_capital_response.g.dart';

@JsonSerializable()
class AddCapitalResponse extends BaseResponse {
  final Capital capital;

  AddCapitalResponse(
      {required int status, required String message,required this.capital,})
      : super(status: status, message: message);

  factory AddCapitalResponse.fromJson(Map<String, dynamic> json) =>
      _$AddCapitalResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AddCapitalResponseToJson(this);
}
