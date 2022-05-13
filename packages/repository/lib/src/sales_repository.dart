import 'dart:io';
import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'sales_repository.g.dart';

@RestApi()
abstract class SalesRepository{
  factory SalesRepository(Dio dio,{String baseUrl}) = _SalesRepository;

  @GET('/sales')
  Future<SalesResponse?> getSales(@Query('groupName') String groupName);

  @POST('/sales')
  Future<AddSalesResponse?> addSales(@Body() AddSales body,);

  @POST('/sales/{id}/uploadReceipt')
  @MultiPart()
  Future<BaseResponse?> uploadReceipt(@Path('id') int id,
      @Part(value: 'receipt') File receipt,);

  @GET('/sales/{id}/lastPower')
  Future<SalesWithPowerResponse?> getLastSalesWithPower(@Path('id') int id,);

}