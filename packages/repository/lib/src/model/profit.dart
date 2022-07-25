import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'profit.g.dart';

@JsonSerializable()
class Profit {
  final int? id;
  final String groupName;
  final String uid;
  final String? description;
  final DateTime date;
  final int total;
  final User? user;

  Profit({
    required this.groupName,
    this.id,
    required this.uid,
    this.description,
    required this.date,
    required this.total,
    this.user,
  });


  factory Profit.fromJson(Map<String, dynamic> json) =>
      _$ProfitFromJson(json);

  Map<String, dynamic> toJson() => _$ProfitToJson(this);
}
