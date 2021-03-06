import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'capital.g.dart';

@JsonSerializable()
class Capital {
  final int? id;
  final String groupName;
  final String uid;
  final DateTime date;
  final int total;
  final String? description;
  final int? expenseId;
  final User? user;

  Capital({
    required this.groupName,
    this.id,
    required this.uid,
    required this.date,
    required this.total,
    this.description,
    this.user,
    this.expenseId,
  });

  factory Capital.fromJson(Map<String, dynamic> json) =>
      _$CapitalFromJson(json);

  Map<String, dynamic> toJson() => _$CapitalToJson(this);
}
