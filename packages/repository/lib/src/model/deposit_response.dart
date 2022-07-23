import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'deposit_response.g.dart';

@JsonSerializable()
class DepositResponse extends BaseResponse {
  final List<Deposit> deposits;

  DepositResponse(
      {required int status, required String message,required this.deposits,})
      : super(status: status, message: message);

  factory DepositResponse.fromJson(Map<String, dynamic> json) =>
      _$DepositResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DepositResponseToJson(this);
}
