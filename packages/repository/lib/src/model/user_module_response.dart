import 'package:json_annotation/json_annotation.dart';
import 'model.dart';

part 'user_module_response.g.dart';

@JsonSerializable()
class UserModuleResponse extends BaseResponse {
  final List<String> modules;

  UserModuleResponse(
      {required int status, required String message, required this.modules, })
      : super(status: status, message: message);

  factory UserModuleResponse.fromJson(Map<String, dynamic> json) =>
      _$UserModuleResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserModuleResponseToJson(this);
}
