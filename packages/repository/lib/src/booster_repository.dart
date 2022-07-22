import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'booster_repository.g.dart';

@RestApi()
abstract class BoosterRepository {
  factory BoosterRepository(Dio dio, {String baseUrl}) = _BoosterRepository;

  @GET('/booster')
  Future<BoosterResponse?> getBooster({
    @Query('groupName') required String groupName,
  });

  @POST('/booster/{id}/deactivate')
  Future<BaseResponse?> deactivate(@Path('id') int id);

  @POST('/booster')
  Future<BaseResponse?> addBoost(@Body() Booster body);

}
