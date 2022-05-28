import 'package:json_annotation/json_annotation.dart';
import 'model.dart';

part 'user_groups_response.g.dart';

@JsonSerializable()
class UserGroupsResponse extends BaseResponse {
  final List<String> groups;

  UserGroupsResponse(
      {required int status, required String message, required this.groups, })
      : super(status: status, message: message);

  factory UserGroupsResponse.fromJson(Map<String, dynamic> json) =>
      _$UserGroupsResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserGroupsResponseToJson(this);
}
