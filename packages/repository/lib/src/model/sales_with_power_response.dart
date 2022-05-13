import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'sales_with_power_response.g.dart';

@JsonSerializable()
class SalesWithPowerResponse extends BaseResponse {
  final Sales? sales;

  SalesWithPowerResponse(
      {required int status, required String message, this.sales})
      : super(status: status, message: message);

  factory SalesWithPowerResponse.fromJson(Map<String, dynamic> json) =>
      _$SalesWithPowerResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SalesWithPowerResponseToJson(this);
}