
import 'package:hive_flutter/hive_flutter.dart';

part 'local_user.g.dart';

@HiveType(typeId: 0)
class LocalUser {

  @HiveField(0)
  List<String>? roles;

  @HiveField(1)
  List<String>? modules;

  @HiveField(2)
  List<String>? groups;

}