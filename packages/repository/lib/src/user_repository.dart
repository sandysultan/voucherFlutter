import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'user_repository.g.dart';

@RestApi()
abstract class UserRepository{
  factory UserRepository(Dio dio,{String baseUrl}) = _UserRepository;

  @GET('/user/{uid}/roles_and_groups')
  Future<UserRolesResponse?> rolesAndGroups(@Path('uid') String uid);

  @GET('/user/{uid}/modules')
  Future<UserModuleResponse?> getUserModules(@Path('uid') String uid);

  @GET('/user/{uid}/groups')
  Future<UserGroupsResponse?> getGroup(@Query('module') String module);

  @POST('/user/{uid}/updateFcm')
  Future<BaseResponse?> updateFcm(@Field('fcm') String fcm);

  @POST('/user/{uid}/deleteFcm')
  Future<BaseResponse?> deleteFcm();
}