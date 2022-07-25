import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'asset.g.dart';

@JsonSerializable()
class Asset {
  final int id;
  final String groupName;
  final String uid;
  final DateTime date;
  final int total;
  final int? expenseId;
  final double? percentage;
  final User user;
  final Expense? expense;

  Asset({
    required this.groupName,
    required this.id,
    required this.uid,
    required this.date,
    required this.total,
    required this.user,
    this.percentage,
    this.expenseId,
    this.expense,
  });
  Asset copy({int? id,
    String? groupName,
    String? uid,
    DateTime? date,
    int? total,
    double? percentage,
    int? expenseId,
    User? user,}) {
    return Asset(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      uid: uid ?? this.uid,
      date: date ?? this.date,
      total: total ?? this.total,
      percentage: percentage ?? this.percentage,
      expenseId: expenseId ?? this.expenseId,
      user: user ?? this.user,
    );
  }

  factory Asset.fromJson(Map<String, dynamic> json) =>
      _$AssetFromJson(json);

  Map<String, dynamic> toJson() => _$AssetToJson(this);
}
