import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'add_expense_response.g.dart';

@JsonSerializable()
class AddExpenseResponse extends BaseResponse {
  final Expense expense;

  AddExpenseResponse(
      {required int status, required String message, required this.expense})
      : super(status: status, message: message);

  factory AddExpenseResponse.fromJson(Map<String, dynamic> json) =>
      _$AddExpenseResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AddExpenseResponseToJson(this);
}