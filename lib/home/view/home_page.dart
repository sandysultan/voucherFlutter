import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:voucher/constant/app_constant.dart';
import 'package:voucher/expense/expense.dart';
import 'package:voucher/login/login.dart';
import 'package:voucher/notification/notification.dart';
import 'package:voucher/sales/sales.dart';
import 'package:voucher/sales_report/sales_report.dart';
import 'package:voucher/transfer/transfer.dart';
import 'package:voucher/transfer_report/transfer_report.dart';
import 'package:voucher/user/view/user_page.dart';

import '../home.dart';

//used for resetting state, so it can triggered twice
const int actionNothing = 0;
const int actionSortByName = 1;
const int actionSortByDays = 2;
const int actionAddExpense = 3;
const int actionAllKiosk = 4;
const int actionActiveKioskOnly = 5;

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {


  void setupToken() {
    // Get the token each time the application loads
    FirebaseMessaging.instance.getToken().then((token)
    {
      context.read<HomeBloc>().add(UpdateFCM(token??""));
    });

    // Save the initial token to the database


    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(((token){
      context.read<HomeBloc>().add(UpdateFCM(token));
    }));
  }


  @override
  void initState() {
    logger.d('uid: ${FirebaseAuth.instance.currentUser!.uid}');

    setupToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        EasyLoading.showInfo(message.notification?.body??"");
        // print('Message also contained a notification: ${message.notification}');
      }
    });
    context
        .read<HomeBloc>()
        .add(LoadModules(FirebaseAuth.instance.currentUser!.uid));
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
                    content: Text(state.message),
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
          context.read<LocalRepository>().updateModules(state.modules);
          return HomeScaffold(logout);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    context.read<HomeBloc>().add(const UpdateFCM(null));
    FirebaseAuth.instance.signOut().then((value) {
      context.read<LocalRepository>().clear();
      Navigator.of(context).pushAndRemoveUntil<void>(
        LoginPage.route(),
        (route) => false,
      );
    });
  }
}

class HomeScaffold extends StatefulWidget {
  const HomeScaffold(
    // this.modules,
    this.onLogout, {
    Key? key,
  }) : super(key: key);
  // final List<String> modules;
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
        child: DrawerListView((value) {
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
      case ModuleConstant.user:
        _activePage = const UserPage();
        break;
      case ModuleConstant.sale:
        _activePage = const SalesPage();
        break;
      case ModuleConstant.transfer:
        _activePage = const TransferPage();
        break;
      case ModuleConstant.salesReport:
        _activePage = const SalesReportPage();
        break;
      case ModuleConstant.transferReport:
        _activePage = const TransferReportPage();
        break;
      case ModuleConstant.expense:
        _activePage = const ExpensePage();
        break;
      default:
        _activePage = const NotificationPage();
    }
    return _activePage;
  }

  List<Widget> getActions(String? module) {
    switch (module) {
      case ModuleConstant.expense:
        return [
          IconButton(onPressed: (){
            context.read<HomeBloc>().add(const AppbarAction(actionAddExpense));
            context.read<HomeBloc>().add(const AppbarAction(actionNothing));
          }, icon: const Icon(Icons.add))
        ];
      case ModuleConstant.sale:
        return [
          PopupMenuButton<int>(
              onSelected: (value) {
                context.read<HomeBloc>().add(AppbarAction(value));
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.filter_alt),
              ),
              itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                      value: actionAllKiosk,
                      child: Text('All Kiosk'),
                    ),
                    const PopupMenuItem<int>(
                      value: actionActiveKioskOnly,
                      child: Text('Active Kiosk Only'),
                    ),
                  ]),
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
      case ModuleConstant.sale:
        return 'Sales';
      case ModuleConstant.salesReport:
        return 'Sales Report';
      case ModuleConstant.transfer:
        return 'Transfer';
      case ModuleConstant.transferReport:
        return 'Transfer Report';
      case ModuleConstant.expense:
        return 'Expenses';
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
                      onChanged: (value) {
                        newPassword = value;
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
                      decoration: const InputDecoration(
                          label: Text("Confirm New Password")),
                      obscureText: true,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        (value) {
                          if (value != newPassword) {
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
                      if (formKey.currentState?.saveAndValidate() == true) {
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
    if (values != null) {
      firebase.User? user = FirebaseAuth.instance.currentUser;

      try {
        EasyLoading.show(status: 'Changing password');
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: values['email'],
          password: values['password'],
        );

        user?.updatePassword(values['newPassword']).then((_) {
          EasyLoading.showSuccess("Password changed");
          widget.onLogout(context);
        }).catchError((error) {
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
  const DrawerListView(this.onModuleChanged, {Key? key}) : super(key: key);
  // final List<String> modules;
  final ValueChanged<String> onModuleChanged;
  @override
  Widget build(BuildContext context) {
    List<Widget> list = populateMenu(context);
    return ListView(
      children: list,
    );
  }

  List<Widget> populateMenu(BuildContext context) {
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

    List<String> modules =
        context.read<LocalRepository>().currentUser()?.modules ?? [];
    list.add(ListTile(
          title: const Text('Notification'),
          onTap: () async {
            onModuleChanged('Notification');
          },
        ));
    // if (modules.contains(ModuleConstant.module)) {
    //   list.add(ListTile(
    //     title: const Text('Modules'),
    //     onTap: () async {
    //       onModuleChanged(ModuleConstant.module);
    //     },
    //   ));
    // }
    // if (modules.contains(ModuleConstant.role)) {
    //   list.add(ListTile(
    //     title: const Text('Roles'),
    //     onTap: () async {
    //       onModuleChanged(ModuleConstant.role);
    //     },
    //   ));
    // }
    // if (modules.contains(ModuleConstant.user)) {
    //   list.add(ListTile(
    //     title: const Text('Users'),
    //     onTap: () async {
    //       onModuleChanged(ModuleConstant.user);
    //     },
    //   ));
    // }
    // if (modules.contains(ModuleConstant.kiosk)) {
    //   list.add(ListTile(
    //     title: const Text('Kiosks'),
    //     onTap: () async {
    //       onModuleChanged(ModuleConstant.kiosk);
    //     },
    //   ));
    // }
    if (modules.contains(ModuleConstant.sale)) {
      list.add(ListTile(
        title: const Text('Sales'),
        onTap: () async {
          onModuleChanged(ModuleConstant.sale);
        },
      ));
    }
    if (modules.contains(ModuleConstant.salesReport)) {
      list.add(ListTile(
        title: const Text('Sales Report'),
        onTap: () async {
          onModuleChanged(ModuleConstant.salesReport);
        },
      ));
    }
    if (modules.contains(ModuleConstant.expense)) {
      list.add(ListTile(
        title: const Text('Expenses'),
        onTap: () async {
          onModuleChanged(ModuleConstant.expense);
        },
      ));
    }

    if (modules.contains(ModuleConstant.transfer)) {
      list.add(ListTile(
        title: const Text('Transfer'),
        onTap: () async {
          onModuleChanged(ModuleConstant.transfer);
        },
      ));
    }
    if (modules.contains(ModuleConstant.transferReport)) {
      list.add(ListTile(
        title: const Text('Transfer Report'),
        onTap: () async {
          onModuleChanged(ModuleConstant.transferReport);
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
