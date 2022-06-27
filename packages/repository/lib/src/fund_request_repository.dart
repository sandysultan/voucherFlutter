import 'dart:io';
import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'fund_request_repository.g.dart';

@RestApi()
abstract class FundRequestRepository{
  factory FundRequestRepository(Dio dio,{String baseUrl}) = _FundRequestRepository;

  @GET('/fund_request')
  Future<FundRequestResponse?> getFundRequest({@Query('paid') bool? paid,@Query('year') int? year,@Query('month') int? month});

  @POST('/fund_request')
  Future<AddFundRequestResponse?> addFundRequest(@Body() FundRequest body,);

  @POST('/fund_request/{id}/uploadReceipt')
  @MultiPart()
  Future<BaseResponse?> uploadReceipt(@Path('id') int id,
      @Part(value: 'receipt') File receipt,);



}