import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'sales_response.g.dart';

@JsonSerializable()
class SalesResponse extends BaseResponse {
  final List<Kiosk>? kiosks;
  final List<Sales>? sales;

  SalesResponse(
      {required int status, required String message, this.kiosks, this.sales})
      : super(status: status, message: message);

  factory SalesResponse.fromJson(Map<String, dynamic> json) =>
      _$SalesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SalesResponseToJson(this);
}