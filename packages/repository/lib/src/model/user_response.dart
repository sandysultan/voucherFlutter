import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'user_response.g.dart';

@JsonSerializable()
class UserResponse extends BaseResponse {
  final List<User> users;

  UserResponse(
      {required int status, required String message, required this.users})
      : super(status: status, message: message);

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}