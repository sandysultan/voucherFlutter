import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'sales_repository.g.dart';

@RestApi()
abstract class SalesRepository{
  factory SalesRepository(Dio dio,{String baseUrl}) = _SalesRepository;

  @GET('/sales')
  Future<SalesResponse?> getSales(@Query('groupName') String groupName);
}