import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  final int? id;
  final int? fundRequestId;
  final int expenseTypeId;
  final DateTime date;
  final String groupName;
  final int total;
  final bool closed;
  final String description;
  final String? createdBy;
  final User? user;
  @JsonKey(name: 'expense_type')
  final ExpenseType? expenseType;



  Expense({
    this.id,
    this.fundRequestId,
    this.expenseType,
    required this.expenseTypeId,
    required this.date,
    required this.groupName,
    required this.total,
    required this.closed,
    required this.description,
    this.createdBy,
    this.user,
  });


  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
