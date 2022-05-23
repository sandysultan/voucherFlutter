import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:repository/repository.dart';
import 'package:voucher/login/login.dart';
import 'package:voucher/sales/sales.dart';
import 'package:voucher/transfer/transfer.dart';
import 'package:voucher/user/view/user_page.dart';

import '../home.dart';

const int actionSortByName=0;
const int actionSortByDays=1;

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: FirebaseAuth.instance.currentUser?.getIdToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return BlocProvider(
            create: (context) => HomeBloc(snapshot.data!),
            child: const HomeView(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    logger.d('uid: '+ FirebaseAuth.instance.currentUser!.uid);
    context
        .read<HomeBloc>()
        .add(LoadRolesAndGroups(FirebaseAuth.instance.currentUser!.uid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      buildWhen: (previous,current)=>current is RoleLoaded || current is EmptyRole,
      listener: (context, state) {
        if (state is EmptyRole) {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: const Text(
                        'You don' 't have any role, please contact admin'),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            await logout(context);
                          },
                          child: const Text('OK'))
                    ],
                  ));
        }
      },
      builder: (context, state) {
        if (state is RoleLoaded) {
          return HomeScaffold(state.roles, state.groups, logout);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil<void>(
      LoginPage.route(),
      (route) => false,
    );
  }
}

class HomeScaffold extends StatefulWidget {
  const HomeScaffold(
    this.roles,
    this.groups,
    this.onLogout, {
    Key? key,
  }) : super(key: key);
  final List<Role> roles;
  final List<Group> groups;
  final Function(BuildContext context) onLogout;

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  String? _module;
  final logger = Logger();

  Widget? _activePage;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle(_module)),
        actions: getActions(_module),
      ),
      drawer: Drawer(
        child: DrawerListView(widget.roles, widget.groups, (value) async {
          if (value == 'logout') {
            await widget.onLogout(context);
          } else {
            setState(() {
              _module = value;
            });
            Navigator.pop(context);
          }
        }),
      ),
      body: getChild(_module),
    );
  }

  getChild(String? module) {
    //todo
    switch (module) {
      case 'user':
        _activePage = const UserPage();
        break;
      case 'sale':
        _activePage = const SalesPage();
        break;
      case 'transfer':
        _activePage = const TransferPage();
        break;
      default:
        _activePage = Center(child: Image.asset('assets/construction.png'),);
    }
    return _activePage;
  }

  List<Widget> getActions(String? module) {
    switch (module) {
      case 'sale':
        return [
          PopupMenuButton<int>(
            onSelected: (value){
              context.read<HomeBloc>().add(AppbarAction(value));
            },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.sort),
              ),
              itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                      value: actionSortByName,
                      child: Text('Sort By Name'),
                    ),
                    const PopupMenuItem<int>(
                      value: actionSortByDays,
                      child: Text('Sort By Days'),
                    ),
                  ])
        ];
      default:
        return [];
    }
  }

  String getTitle(String? module) {
    switch (module) {
      case 'sale':
        return 'Sales';
      case 'transfer':
        return 'Transfer';

    }
    return 'iVoucher';
  }
}

class DrawerListView extends StatelessWidget {
  const DrawerListView(this.roles, this.groups, this.onModuleChanged,
      {Key? key})
      : super(key: key);
  final List<Role> roles;
  final List<Group> groups;
  final ValueChanged<String> onModuleChanged;
  @override
  Widget build(BuildContext context) {
    List<Widget> list = populateMenuAndGroups(context, roles, groups);
    return ListView(
      children: list,
    );
  }

  List<Widget> populateMenuAndGroups(
      BuildContext context, List<Role> roles, List<Group> groups) {
    var list = <Widget>[
      DrawerHeader(
        child: Column(
          children: [
            Text(FirebaseAuth.instance.currentUser?.email ?? "",
              style: const TextStyle(color: Colors.white),),
            FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.done) {
                    return Text(
                      "Version : " + snapshot.requireData.version,
                      style: const TextStyle(color: Colors.white),
                    );
                  } else {
                    return Container();
                  }
                }),
          ],
        ),
        decoration: const BoxDecoration(color: Colors.blue),
      )
    ];
    List<String> modules = [];
    List<String> sgroups = [];
    List<String> sRoles = [];
    for (var role in roles) {
      sRoles.add(role.name);
      for (var appModule in role.appModules) {
        modules.add(appModule.name);
      }
    }
    for (var group in groups) {
      sgroups.add(group.groupName);
    }

    context
        .read<LocalRepository>()
        .updateRolesModulesGroups(sRoles, modules, sgroups);
    modules = modules.toSet().toList();
    if (modules.contains('module')) {
      list.add(ListTile(
        title: const Text('Modules'),
        onTap: () async {
          onModuleChanged('module');
        },
      ));
    }
    if (modules.contains('role')) {
      list.add(ListTile(
        title: const Text('Roles'),
        onTap: () async {
          onModuleChanged('role');
        },
      ));
    }
    if (modules.contains('user')) {
      list.add(ListTile(
        title: const Text('Users'),
        onTap: () async {
          onModuleChanged('user');
        },
      ));
    }
    if (modules.contains('kiosk')) {
      list.add(ListTile(
        title: const Text('Kiosks'),
        onTap: () async {
          onModuleChanged('kiosk');
        },
      ));
    }
    if (modules.contains('sale')) {
      list.add(ListTile(
        title: const Text('Sales'),
        onTap: () async {
          onModuleChanged('sale');
        },
      ));
    }
    if (modules.contains('transfer')) {
      list.add(ListTile(
        title: const Text('Transfer'),
        onTap: () async {
          onModuleChanged('transfer');
        },
      ));
    }
    list.addAll([
      const Divider(),
      ListTile(
        title: const Text('Logout'),
        onTap: () async {
          onModuleChanged('logout');
        },
      ),
    ]);
    return list;
  }
}
