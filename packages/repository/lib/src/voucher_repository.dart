import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'voucher_repository.g.dart';

@RestApi()
abstract class VoucherRepository{
  factory VoucherRepository(Dio dio,{String baseUrl}) = _VoucherRepository;

  @GET('/voucher')
  Future<VoucherResponse?> getVoucher();
}