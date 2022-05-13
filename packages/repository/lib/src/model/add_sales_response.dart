import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'add_sales_response.g.dart';

@JsonSerializable()
class AddSalesResponse extends BaseResponse {
  final Sales sales;

  AddSalesResponse(
      {required int status, required String message, required this.sales})
      : super(status: status, message: message);

  factory AddSalesResponse.fromJson(Map<String, dynamic> json) =>
      _$AddSalesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AddSalesResponseToJson(this);
}