
import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'asset_repository.g.dart';

@RestApi()
abstract class AssetRepository {
  factory AssetRepository(Dio dio, {String baseUrl}) = _AssetRepository;

  @GET('/asset')
  Future<AssetResponse?> getAssets({
    @Query('groupName') String? groupName,
    @Query('year') int? year,
    @Query('month') int? month,
  });


}
