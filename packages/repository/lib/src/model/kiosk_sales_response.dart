import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'kiosk_sales_response.g.dart';

@JsonSerializable()
class KioskSalesResponse extends BaseResponse {
  final List<Sales>? sales;
  final bool? isLast;

  KioskSalesResponse(
      {required int status, required String message, this.sales,this.isLast})
      : super(status: status, message: message);

  factory KioskSalesResponse.fromJson(Map<String, dynamic> json) =>
      _$KioskSalesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$KioskSalesResponseToJson(this);
}