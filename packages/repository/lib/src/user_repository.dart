import 'package:dio/dio.dart';
import 'package:repository/src/model/model.dart';
import 'package:retrofit/retrofit.dart';

part 'user_repository.g.dart';

@RestApi()
abstract class UserRepository{
  factory UserRepository(Dio dio,{String baseUrl}) = _UserRepository;

  @GET('/user/{uid}/roles_and_groups')
  Future<UserRolesResponse?> rolesAndGroups(@Path('uid') String uid);
}