import 'package:dio/dio.dart';
import 'package:repository/src/model/kiosk_sales_response.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'group_repository.g.dart';

@RestApi()
abstract class GroupRepository{
  factory GroupRepository(Dio dio,{String baseUrl}) = _GroupRepository;


  @GET('/group/{groupName}/vouchers')
  Future<GroupVoucherResponse?> getVouchers(@Path('groupName') String groupName);

}