import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  final int? id;
  final int? fundRequestId;
  final DateTime date;
  final String groupName;
  final int total;
  final bool closed;
  final String description;
  final String? createdBy;
  final User? user;



  Expense({
    this.id,
    this.fundRequestId,
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
