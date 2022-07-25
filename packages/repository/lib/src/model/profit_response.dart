import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'profit_response.g.dart';

@JsonSerializable()
class ProfitResponse extends BaseResponse {
  final List<Profit> profits;

  ProfitResponse(
      {required int status, required String message,required this.profits,})
      : super(status: status, message: message);

  factory ProfitResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfitResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProfitResponseToJson(this);
}
