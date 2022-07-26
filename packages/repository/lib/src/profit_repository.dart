
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'profit_repository.g.dart';

@RestApi()
abstract class ProfitRepository {
  factory ProfitRepository(Dio dio, {String baseUrl}) = _ProfitRepository;

  @GET('/profit')
  Future<ProfitResponse?> getProfits({
    @Query('groupName') required String groupName,
    @Query('year') required int year,
    @Query('month') required int month,
  });

  @POST('/profit/convert')
  Future<BaseResponse?>  convertProfit({
    @Body() required Profit profit,
  });

  @POST('/profit')
  Future<ProfitTransferResponse?>  profitTransfer(@Body() Profit body,);

  @POST('/profit/{id}/uploadReceipt')
  @MultiPart()
  Future<BaseResponse?> uploadReceipt(@Path('id') int id,
      @Part(value: 'receipt') File receipt,);

}
