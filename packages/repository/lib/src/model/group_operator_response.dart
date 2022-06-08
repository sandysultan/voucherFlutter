import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'group_operator_response.g.dart';

@JsonSerializable()
class GroupOperatorResponse extends BaseResponse {
  final List<User> operators;

  GroupOperatorResponse(
      {required int status, required String message, required this.operators})
      : super(status: status, message: message);

  factory GroupOperatorResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupOperatorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GroupOperatorResponseToJson(this);
}