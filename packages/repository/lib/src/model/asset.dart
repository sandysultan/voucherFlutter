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
  final int expenseId;
  final User user;

  Asset({
    required this.groupName,
    required this.id,
    required this.uid,
    required this.date,
    required this.total,
    required this.user,
    required this.expenseId,
  });

  factory Asset.fromJson(Map<String, dynamic> json) =>
      _$AssetFromJson(json);

  Map<String, dynamic> toJson() => _$AssetToJson(this);
}
