import 'package:dio/dio.dart';
import 'package:repository/src/model/kiosk_sales_response.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'kiosk_repository.g.dart';

@RestApi()
abstract class KioskRepository{
  factory KioskRepository(Dio dio,{String baseUrl}) = _KioskRepository;

  @GET('/kiosk/{id}/lastPowerSale')
  Future<SalesWithPowerResponse?> getLastSalesWithPower(@Path('id') int id,);

  @GET('/kiosk/{id}/sales')
  Future<KioskSalesResponse?> getSales(@Path('id') int id,@Query('year') int year,@Query('month') int? month);

  @POST('/kiosk/{id}')
  Future<KioskUpdateResponse?> update(@Path('id') int id,@Body() Kiosk kiosk);

}