import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'add_transfer_response.g.dart';

@JsonSerializable()
class AddTransferResponse extends BaseResponse {
  final Transfer transfer;

  AddTransferResponse(
      {required int status, required String message, required this.transfer})
      : super(status: status, message: message);

  factory AddTransferResponse.fromJson(Map<String, dynamic> json) =>
      _$AddTransferResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AddTransferResponseToJson(this);
}