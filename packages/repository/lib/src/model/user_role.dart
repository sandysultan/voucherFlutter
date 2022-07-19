import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'user_role.g.dart';

@JsonSerializable()
class UserRole {
  final int id;
  final String roleName;
  final String uid;
  final List<Group> groups;

  UserRole({
    required this.id,
    required this.roleName,
    required this.uid,
    required this.groups,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) => _$UserRoleFromJson(json);
  Map<String, dynamic> toJson() => _$UserRoleToJson(this);

}
