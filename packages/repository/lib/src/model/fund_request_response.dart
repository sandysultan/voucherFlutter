import 'package:repository/src/model/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'fund_request_response.g.dart';

@JsonSerializable()
class FundRequestResponse extends BaseResponse {
  final List<FundRequest> fundRequests;

  FundRequestResponse(
      {required int status, required String message,required this.fundRequests,})
      : super(status: status, message: message);

  factory FundRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$FundRequestResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FundRequestResponseToJson(this);
}
