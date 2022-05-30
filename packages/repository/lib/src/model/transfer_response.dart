import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'transfer_response.g.dart';

@JsonSerializable()
class TransferResponse extends BaseResponse {
  final List<Transfer> transfers;

  TransferResponse(
      {required int status, required String message, required this.transfers})
      : super(status: status, message: message);

  factory TransferResponse.fromJson(Map<String, dynamic> json) =>
      _$TransferResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TransferResponseToJson(this);
}