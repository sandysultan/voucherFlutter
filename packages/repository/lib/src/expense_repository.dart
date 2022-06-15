import 'dart:io';
import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'expense_repository.g.dart';

@RestApi()
abstract class ExpenseRepository{
  factory ExpenseRepository(Dio dio,{String baseUrl}) = _ExpenseRepository;

  @POST('/expense')
  Future<AddExpenseResponse?> addExpense(@Body() Expense body,);

  @GET('/expense')
  Future<ExpenseResponse?> getExpense(
      {@Query('groupName') required  String groupName,
      @Query('year') required int year,
      @Query('month') required int month});

  @GET('/expense_type')
  Future<ExpenseTypeResponse?> getExpenseTypes();

  @POST('/expense/{id}/uploadReceipt')
  @MultiPart()
  Future<BaseResponse?> uploadReceipt(@Path('id') int id,
      @Part(value: 'receipt') File receipt,);


}