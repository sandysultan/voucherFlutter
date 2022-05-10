import 'package:json_annotation/json_annotation.dart';
import 'model.dart';

part 'user_roles_response.g.dart';

@JsonSerializable()
class UserRolesResponse extends BaseResponse {
  final List<Role> roles;
  final List<Group> groups;

  UserRolesResponse(
      {required int status, required String message, required this.roles, required this.groups, })
      : super(status: status, message: message);

  factory UserRolesResponse.fromJson(Map<String, dynamic> json) =>
      _$UserRolesResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserRolesResponseToJson(this);
}
