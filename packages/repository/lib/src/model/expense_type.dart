import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'expense_type.g.dart';

@JsonSerializable()
class ExpenseType {
  final int id;
  final String expenseTypeName;
  final bool asset;



  ExpenseType({
    required this.id,
    required this.expenseTypeName,
    required this.asset,
  });


  factory ExpenseType.fromJson(Map<String, dynamic> json) => _$ExpenseTypeFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseTypeToJson(this);
}
