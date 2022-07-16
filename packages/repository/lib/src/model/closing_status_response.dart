import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'closing_status_response.g.dart';

@JsonSerializable()
class StatusClosingResponse extends BaseResponse {
  final int? year;
  final int? month;
  final List<Capital>? capitals;
  final List<Expense>? expenses;
  final List<Sales>? sales;
  final List<Booster>? boosters;

  StatusClosingResponse(
      {required int status,
      required String message,
      this.year,
      this.month,
      this.capitals,
      this.expenses,
      this.sales,
      this.boosters})
      : super(status: status, message: message);

  factory StatusClosingResponse.fromJson(Map<String, dynamic> json) =>
      _$StatusClosingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StatusClosingResponseToJson(this);
}
