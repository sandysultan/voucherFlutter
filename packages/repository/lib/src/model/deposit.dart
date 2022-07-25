import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'deposit.g.dart';

@JsonSerializable()
class Deposit {
  final int id;
  final String groupName;
  final String uid;
  final DateTime date;
  final int total;
  final String? description;
  final int? expenseId;
  final User? user;

  Deposit({
    required this.groupName,
    required this.id,
    required this.uid,
    required this.date,
    required this.total,
    this.description,
    this.user,
    this.expenseId,
  });

  factory Deposit.fromJson(Map<String, dynamic> json) =>
      _$DepositFromJson(json);

  Map<String, dynamic> toJson() => _$DepositToJson(this);

  Deposit copy({int? id,
  String? groupName,
  String? uid,
  DateTime? date,
  int? total,
  String? description,
  int? expenseId,
  User? user,}) {
    return Deposit(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      uid: uid ?? this.uid,
      date: date ?? this.date,
      total: total ?? this.total,
      description: description ?? this.description,
      expenseId: expenseId ?? this.expenseId,
      user: user ?? this.user,
    );
  }
}
