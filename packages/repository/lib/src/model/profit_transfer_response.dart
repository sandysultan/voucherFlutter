import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'profit_transfer_response.g.dart';

@JsonSerializable()
class ProfitTransferResponse extends BaseResponse {
  final Profit profit;

  ProfitTransferResponse(
      {required int status, required String message,required this.profit,})
      : super(status: status, message: message);

  factory ProfitTransferResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfitTransferResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProfitTransferResponseToJson(this);
}
