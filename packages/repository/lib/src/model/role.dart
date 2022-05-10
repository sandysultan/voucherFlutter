import 'package:json_annotation/json_annotation.dart';
import 'package:repository/repository.dart';
import 'package:repository/src/model/app_module.dart';

part 'role.g.dart';

@JsonSerializable()
class Role{
  final String name;
  final List<AppModule> appModules;

  Role({required this.name,
    required this.appModules
  });


  factory Role.fromJson(Map<String, dynamic> json) =>
      _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}