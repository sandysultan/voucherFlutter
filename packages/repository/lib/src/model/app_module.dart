import 'package:json_annotation/json_annotation.dart';

part 'app_module.g.dart';

@JsonSerializable()
class AppModule{
  final String name;

  AppModule({required this.name});


  factory AppModule.fromJson(Map<String, dynamic> json) =>
      _$AppModuleFromJson(json);
  Map<String, dynamic> toJson() => _$AppModuleToJson(this);
}