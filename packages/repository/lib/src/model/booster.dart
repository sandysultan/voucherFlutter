import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'booster.g.dart';

@JsonSerializable()
class Booster {
  final int id;
  final bool status;
  final String groupName;
  final String uid;
  final double boost;
  final User? user;

  Booster({
    required this.groupName,
    required this.id,
    required this.status,
    required this.uid,
    required this.boost,
    this.user,
  });

  factory Booster.fromJson(Map<String, dynamic> json) =>
      _$BoosterFromJson(json);

  Map<String, dynamic> toJson() => _$BoosterToJson(this);
}
