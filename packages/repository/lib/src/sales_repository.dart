import 'dart:io';
import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'sales_repository.g.dart';

@RestApi()
abstract class SalesRepository{
  factory SalesRepository(Dio dio,{String baseUrl}) = _SalesRepository;

  @GET('/sales')
  Future<SalesResponse?> getSales(
      {@Query('groupName') required String groupName,
      @Query('status') int? status,
      @Query('year') int? year,
      @Query('month') int? month,
      @Query('groupByKiosk') bool? groupByKiosk,
      @Query('fundTransferred') bool? fundTransferred});

  @POST('/sales')
  Future<AddSalesResponse?> addSales(@Body() Sales body,);

  @DELETE('/sales/{id}')
  Future<BaseResponse?> deleteSales(@Path('id') int id,);

  @POST('/sales/{id}/uploadReceipt')
  @MultiPart()
  Future<BaseResponse?> uploadReceipt(@Path('id') int id,
      @Part(value: 'receipt') File receipt,);


  //todo add
  //filename: "salesReceiptWeb.jpg",
  //in g.dart for this
  @POST('/sales/{id}/uploadReceipt')
  @MultiPart()
  Future<BaseResponse?> uploadReceiptForWeb(@Path('id') int id,
      @Part(value: 'receipt') List<int> receipt,);


}