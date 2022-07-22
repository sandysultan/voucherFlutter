import 'dart:io';

import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'capital_repository.g.dart';

@RestApi()
abstract class CapitalRepository {
  factory CapitalRepository(Dio dio, {String baseUrl}) = _CapitalRepository;

  @GET('/capital/investor')
  Future<InvestorResponse?> getInvestors({
    @Query('groupName') required String groupName,
  });

  @GET('/capital')
  Future<CapitalResponse?> getCapitals({
    @Query('groupName') String? groupName,
    @Query('uid') String? uid,
    @Query('year') int? year,
    @Query('month') int? month,
  });

  @POST('/capital')
  Future<AddCapitalResponse?> addCapital(@Body() Capital body,);

  @POST('/capital/{id}/uploadReceipt')
  @MultiPart()
  Future<BaseResponse?> uploadReceipt(@Path('id') int id,
      @Part(value: 'receipt') File receipt,);
}
