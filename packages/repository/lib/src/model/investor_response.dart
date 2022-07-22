import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'investor_response.g.dart';

@JsonSerializable()
class InvestorResponse extends BaseResponse {
  final List<User> users;

  InvestorResponse(
      {required int status, required String message,required this.users,})
      : super(status: status, message: message);

  factory InvestorResponse.fromJson(Map<String, dynamic> json) =>
      _$InvestorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$InvestorResponseToJson(this);
}
