import 'package:json_annotation/json_annotation.dart';
import 'package:repository/repository.dart';
import 'package:repository/src/model/app_module.dart';

part 'group.g.dart';

@JsonSerializable()
class Group{
  final String groupName;

  Group({required this.groupName,
  });


  factory Group.fromJson(Map<String, dynamic> json) =>
      _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);
}