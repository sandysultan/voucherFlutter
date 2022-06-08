import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'expense_response.g.dart';

@JsonSerializable()
class ExpenseResponse extends BaseResponse {
  final List<Expense> expenses;

  ExpenseResponse(
      {required int status, required String message, required this.expenses})
      : super(status: status, message: message);

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpenseResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseResponseToJson(this);
}