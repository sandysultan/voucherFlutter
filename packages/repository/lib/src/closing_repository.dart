import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'closing_repository.g.dart';

@RestApi()
abstract class ClosingRepository{
  factory ClosingRepository(Dio dio,{String baseUrl}) = _ClosingRepository;

  @GET('/closing/getStatus')
  Future<StatusClosingResponse?> getStatus(
      {@Query('groupName') required  String groupName,});

  @GET('/closing/getLastClosing')
  Future<LastClosingResponse?> getLastClosing(
      {@Query('groupName') required  String groupName,});


  @POST('/closing')
  Future<StatusClosingResponse?> close(
      {@Query('groupName') required  String groupName,});


}