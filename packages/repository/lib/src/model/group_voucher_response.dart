import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'group_voucher_response.g.dart';

@JsonSerializable()
class GroupVoucherResponse extends BaseResponse {
  final List<Voucher> vouchers;

  GroupVoucherResponse(
      {required int status, required String message, required this.vouchers})
      : super(status: status, message: message);

  factory GroupVoucherResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupVoucherResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GroupVoucherResponseToJson(this);
}