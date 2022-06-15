import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'expense_type_response.g.dart';

@JsonSerializable()
class ExpenseTypeResponse extends BaseResponse {
  final List<ExpenseType> expenseTypes;

  ExpenseTypeResponse(
      {required int status, required String message, required this.expenseTypes})
      : super(status: status, message: message);

  factory ExpenseTypeResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpenseTypeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseTypeResponseToJson(this);
}