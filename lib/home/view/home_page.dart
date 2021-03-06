import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http_client/http_client.dart';
import 'package:iVoucher/asset/asset.dart';
import 'package:iVoucher/booster/booster.dart';
import 'package:iVoucher/capital/capital.dart';
import 'package:iVoucher/closing/view/closing_page.dart';
import 'package:iVoucher/deposit/deposit.dart';
import 'package:iVoucher/profit/profit.dart';
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:iVoucher/constant/app_constant.dart';
import 'package:iVoucher/expense/expense.dart';
import 'package:iVoucher/fund_request/fund_request.dart';
import 'package:iVoucher/login/login.dart';
import 'package:iVoucher/notification/notification.dart';
import 'package:iVoucher/sales/sales.dart';
import 'package:iVoucher/sales_report/sales_report.dart';
import 'package:iVoucher/transfer/transfer.dart';
import 'package:iVoucher/transfer_report/transfer_report.dart';
import 'package:iVoucher/user/user.dart';

import '../home.dart';

//used for resetting state, so it can triggered twice
const int actionNothing = 0;
const int actionSortByName = 1;
const int actionSortByDays = 2;
const int actionAddExpense = 3;
const int actionAllKiosk = 4;
const int actionActiveKioskOnly = 5;
const int actionAddFundRequest = 6;
const int actionAddCapital = 7;
const int actionAddBooster = 8;
const int actionProfitTransfer = 9;
const int actionProfitCapital = 10;

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
    var localUser = context.read<LocalRepository>().currentUser();
    Logger().d("is dev : ${localUser?.dev}");
    HttpClient.setDev(localUser?.dev??false);
    setupToken();

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
    context.read<LocalRepository>().clear();
    FirebaseAuth.instance.signOut().then((value) {
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
  List<String>? _modules;

  @override
  void initState() {
    _modules = context.read<LocalRepository>().currentUser()?.modules;
    super.initState();
  }

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
      case ModuleConstant.fundRequest:
        _activePage = const FundRequestPage();
        break;
      case ModuleConstant.closing:
        _activePage = const ClosingPage();
        break;
      case ModuleConstant.capital:
        _activePage = const CapitalPage();
        break;
      case ModuleConstant.booster:
        _activePage = const BoosterPage();
        break;
      case ModuleConstant.deposit:
        _activePage = const DepositPage();
        break;
      case ModuleConstant.asset:
        _activePage = const AssetPage();
        break;
      case ModuleConstant.profit:
        _activePage = const ProfitPage();
        break;
      default:
        _activePage = const NotificationPage();
    }
    return _activePage;
  }

  List<Widget> getActions(String? module) {
    switch (module) {
      case ModuleConstant.fundRequest:
        return [
          if(_modules?.contains(ModuleConstant.fundRequestAdd)==true) ...[
            IconButton(onPressed: (){
              context.read<HomeBloc>().add(const AppbarAction(actionAddFundRequest));
              context.read<HomeBloc>().add(const AppbarAction(actionNothing));

            }, icon: const Icon(Icons.add))
          ]
        ];
      case ModuleConstant.expense:
        if(_modules?.contains(ModuleConstant.expenseAdd)==true) {
          return [
            IconButton(onPressed: () {
              context.read<HomeBloc>().add(
                  const AppbarAction(actionAddExpense));
              context.read<HomeBloc>().add(const AppbarAction(actionNothing));
            }, icon: const Icon(Icons.add))
          ];
        }else{
          return [];
        }
      case ModuleConstant.capital:

        if(_modules?.contains(ModuleConstant.capitalAdd)==true) {
          return [
            IconButton(onPressed: (){
              context.read<HomeBloc>().add(const AppbarAction(actionAddCapital));
              context.read<HomeBloc>().add(const AppbarAction(actionNothing));
            }, icon: const Icon(Icons.add))
          ];
        } else {
          return [];
        }
      case ModuleConstant.booster:

        if(_modules?.contains(ModuleConstant.boosterAdd)==true) {
          return [
            IconButton(onPressed: (){
              context.read<HomeBloc>().add(const AppbarAction(actionAddBooster));
              context.read<HomeBloc>().add(const AppbarAction(actionNothing));
            }, icon: const Icon(Icons.add))
          ];
        } else {
          return [];
        }
      case ModuleConstant.profit:
        List<IconButton> buttons=[];
        if(_modules?.contains(ModuleConstant.profitTransfer)==true) {
          buttons.add(IconButton(onPressed: (){
            context.read<HomeBloc>().add(const AppbarAction(actionProfitTransfer));
            context.read<HomeBloc>().add(const AppbarAction(actionNothing));
          }, icon: const Icon(Icons.account_balance_wallet_rounded),tooltip: 'Withdraw',));
        }
        if(_modules?.contains(ModuleConstant.profitCapital)==true) {
          buttons.add(IconButton(onPressed: (){
            context.read<HomeBloc>().add(const AppbarAction(actionProfitCapital));
            context.read<HomeBloc>().add(const AppbarAction(actionNothing));
          }, icon: const Icon(Icons.money),tooltip: 'Convert to Capital',));
        }
        return buttons;
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
      case ModuleConstant.fundRequest:
        return 'Fund Request';
      case ModuleConstant.closing:
        return 'Month Closing';
      case ModuleConstant.capital:
        return 'Capital';
      case ModuleConstant.user:
        return 'Users';
      case ModuleConstant.booster:
        return 'Booster';
      case ModuleConstant.deposit:
        return 'Deposit';
      case ModuleConstant.asset:
        return 'Asset';
      case ModuleConstant.profit:
        return 'Profit';
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
                          return null;
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
        // UserCredential userCredential =
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
        decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
        child: Column(
          children: [
            Text(
              FirebaseAuth.instance.currentUser?.email ?? "",
              style: TextStyle(color: Theme.of(context).primaryTextTheme.titleLarge?.color),
            ),
            FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                      "Version : ${snapshot.requireData.version}",
                      style: TextStyle(color: Theme.of(context).primaryTextTheme.titleLarge?.color),
                    );
                  } else {
                    return Container();
                  }
                }),
            if(HttpClient.debugServer) ...[
              const Text(
                "Connected to development server",
                style: TextStyle(color: Colors.red),
              ),
            ]
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
    if (modules.contains(ModuleConstant.user)) {
      list.add(ListTile(
        title: const Text('Users'),
        onTap: () async {
          onModuleChanged(ModuleConstant.user);
        },
      ));
    }
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
    if (modules.contains(ModuleConstant.fundRequest)) {
      list.add(ListTile(
        title: const Text('Fund Request'),
        onTap: () async {
          onModuleChanged(ModuleConstant.fundRequest);
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
    if (modules.contains(ModuleConstant.closing)) {
      list.add(ListTile(
        title: const Text('Closing'),
        onTap: () async {
          onModuleChanged(ModuleConstant.closing);
        },
      ));
    }
    if (modules.contains(ModuleConstant.closingReport)) {
      list.add(ListTile(
        title: const Text('Closing Report'),
        onTap: () async {
          onModuleChanged(ModuleConstant.closingReport);
        },
      ));
    }
    if (modules.contains(ModuleConstant.capital)) {
      list.add(ListTile(
        title: const Text('Capital'),
        onTap: () async {
          onModuleChanged(ModuleConstant.capital);
        },
      ));
    }
    if (modules.contains(ModuleConstant.booster)) {
      list.add(ListTile(
        title: const Text('Booster'),
        onTap: () async {
          onModuleChanged(ModuleConstant.booster);
        },
      ));
    }
    if (modules.contains(ModuleConstant.deposit)) {
      list.add(ListTile(
        title: const Text('Deposit'),
        onTap: () async {
          onModuleChanged(ModuleConstant.deposit);
        },
      ));
    }
    if (modules.contains(ModuleConstant.asset)) {
      list.add(ListTile(
        title: const Text('Asset'),
        onTap: () async {
          onModuleChanged(ModuleConstant.asset);
        },
      ));
    }
    if (modules.contains(ModuleConstant.profit)) {
      list.add(ListTile(
        title: const Text('Profit'),
        onTap: () async {
          onModuleChanged(ModuleConstant.profit);
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
