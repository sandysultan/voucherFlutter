import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_repository/local_repository.dart';
import 'model/model.dart';

class LocalRepository{

  static const boxName='localUser';

  static init() async{
    await Hive.initFlutter();
    Hive.registerAdapter(LocalUserAdapter());
    await Hive.openBox<LocalUser>(boxName);
  }


  LocalUser? currentUser(){
    final usersBox = Hive.box<LocalUser>(boxName);
    if (usersBox.length > 0) {
      return usersBox.getAt(0);
    }
    return null;
  }

  void updateRolesModulesGroups(List<String> roles, List<String> modules, List<String> groups) {
    final usersBox = Hive.box<LocalUser>(boxName);
    LocalUser user;
    if (usersBox.length <= 0) {
      usersBox.add(LocalUser());
    }
    user = usersBox.getAt(0)!;
    user.roles = roles;
    user.modules = modules;
    user.groups = groups;
  }



}
