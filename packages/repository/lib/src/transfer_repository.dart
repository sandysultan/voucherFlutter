import 'dart:io';
import 'package:dio/dio.dart';
import 'package:repository/src/model/add_transfer_response.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'transfer_repository.g.dart';

@RestApi()
abstract class TransferRepository{
  factory TransferRepository(Dio dio,{String baseUrl}) = _TransferRepository;


  @POST('/transfer')
  Future<AddTransferResponse?> addTransfer(@Body() Transfer body,);

  @POST('/transfer/{id}/uploadReceipt')
  @MultiPart()
  Future<BaseResponse?> uploadReceipt(@Path('id') int id,
      @Part(value: 'receipt') File receipt,);


}