import 'package:json_annotation/json_annotation.dart';
import 'package:repository/src/model/model.dart';

part 'voucher_response.g.dart';

@JsonSerializable()
class VoucherResponse extends BaseResponse {
  final List<Voucher> vouchers;

  VoucherResponse(
      {required int status, required String message, required this.vouchers})
      : super(status: status, message: message);

  factory VoucherResponse.fromJson(Map<String, dynamic> json) =>
      _$VoucherResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VoucherResponseToJson(this);
}