import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:repository/repository.dart';
import 'package:voucher/login/login.dart';
import 'package:voucher/sales/sales.dart';
import 'package:voucher/transfer/transfer.dart';
import 'package:voucher/user/view/user_page.dart';

import '../home.dart';

const int actionSortByName = 0;
const int actionSortByDays = 1;

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
    logger.d('uid: ${FirebaseAuth.instance.currentUser!.uid}');
    context
        .read<HomeBloc>()
        .add(LoadRolesAndGroups(FirebaseAuth.instance.currentUser!.uid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          current is RoleLoaded || current is EmptyRole,
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
    FirebaseAuth.instance
        .signOut()
        .then((value) => Navigator.of(context).pushAndRemoveUntil<void>(
              LoginPage.route(),
              (route) => false,
            ));
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
        child: DrawerListView(widget.roles, widget.groups, (value) {
          if (value == 'logout') {
            widget.onLogout(context);
          }
          if (value == 'password') {
            Navigator.pop(context);
            changePassword();
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
        _activePage = Center(
          child: Image.asset('assets/construction.png'),
        );
    }
    return _activePage;
  }

  List<Widget> getActions(String? module) {
    switch (module) {
      case 'sale':
        return [
          PopupMenuButton<int>(
              onSelected: (value) {
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

  void changePassword() async {
    var formKey = GlobalKey<FormBuilderState>();
    // var newPasswordController=TextEditingController();
    String? newPassword;
    var values = await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Change Password'),
              content: FormBuilder(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: "email",
                      // initialValue: kDebugMode ? "sandysultan@gmail.com" : "",
                      initialValue: kDebugMode ? "emilda.rika@gmail.com" : "",
                      // initialValue:
                      //     kDebugMode ? "dianrosadi2020@gmail.com" : "",
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        label: Text("Email"),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.email(),
                        FormBuilderValidators.required()
                      ]),
                    ),
                    FormBuilderTextField(
                      name: "password",
                      // initialValue: kDebugMode ? "sr@1nkD4Yiv" : "",
                      initialValue: kDebugMode ? "iVoucher2022" : "",
                      decoration:
                          const InputDecoration(label: Text("Password")),
                      obscureText: true,
                      validator: FormBuilderValidators.required(),
                    ),
                    FormBuilderTextField(
                      name: "newPassword",
                      // initialValue: kDebugMode ? "sr@1nkD4Yiv" : "",
                      initialValue: kDebugMode ? "iVoucher2022" : "",
                      // controller: newPasswordController,
                      onChanged: (value){
                        newPassword=value;
                      },
                      decoration:
                          const InputDecoration(label: Text("New Password")),
                      obscureText: true,
                      validator: FormBuilderValidators.required(),
                    ),
                    FormBuilderTextField(
                      name: "confirmNewPassword",
                      // initialValue: kDebugMode ? "sr@1nkD4Yiv" : "",
                      initialValue: kDebugMode ? "iVoucher2022" : "",
                      decoration:
                          const InputDecoration(label: Text("Confirm New Password")),
                      obscureText: true,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        (value){
                          if(value!=newPassword) {
                            return 'Password not match';
                          }
                        }
                      ]),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      if(formKey.currentState?.saveAndValidate()==true){
                        Navigator.of(context).pop(formKey.currentState?.value);
                      }
                    },
                    child: const Text('Submit')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'))
              ],
            ));
    if(values!=null){

      firebase.User? user = FirebaseAuth.instance.currentUser;

      try {
        EasyLoading.show(status: 'Changing password');
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: values['email'],
          password: values['password'],
        );

        user?.updatePassword(values['newPassword']).then((_){
          EasyLoading.showSuccess("Password changed");
          widget.onLogout(context);
        }).catchError((error){
          EasyLoading.showError("Password can't be changed. $error");
          //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          EasyLoading.showError('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          EasyLoading.showError('Wrong password provided for that user.');
        }
      }
    }
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
        decoration: const BoxDecoration(color: Colors.blue),
        child: Column(
          children: [
            Text(
              FirebaseAuth.instance.currentUser?.email ?? "",
              style: const TextStyle(color: Colors.white),
            ),
            FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                      "Version : ${snapshot.requireData.version}",
                      style: const TextStyle(color: Colors.white),
                    );
                  } else {
                    return Container();
                  }
                }),
          ],
        ),
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
        title: const Text('Change Password'),
        onTap: () async {
          onModuleChanged('password');
        },
      ),
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