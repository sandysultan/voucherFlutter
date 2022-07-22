import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'add_fund_request_response.g.dart';

@JsonSerializable()
class AddFundRequestResponse extends BaseResponse {
  final FundRequest fundRequest;

  AddFundRequestResponse(
      {required int status, required String message,required this.fundRequest,})
      : super(status: status, message: message);

  factory AddFundRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$AddFundRequestResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AddFundRequestResponseToJson(this);
}
