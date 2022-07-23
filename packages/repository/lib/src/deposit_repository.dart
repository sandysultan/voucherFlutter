import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'deposit_repository.g.dart';

@RestApi()
abstract class DepositRepository {
  factory DepositRepository(Dio dio, {String baseUrl}) = _DepositRepository;

  @GET('/deposit')
  Future<DepositResponse?> getDeposits({
    @Query('groupName') String? groupName,
    @Query('year') int? year,
    @Query('month') int? month,
  });


}
