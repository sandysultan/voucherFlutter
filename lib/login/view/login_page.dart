import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:local_repository/local_repository.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:voucher/home/home.dart';
import 'package:voucher/login/login.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Route<String?> route() {
    return MaterialPageRoute<String?>(
      settings: const RouteSettings(name: '/login'),
      builder: (context) => const LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _formKey = GlobalKey<FormBuilderState>();


    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                )),
          ),
          _LoginView(formKey: _formKey),

        ],
      ),
    );
  }

}

class _LoginView extends StatelessWidget {
  const _LoginView({
    Key? key,
    required GlobalKey<FormBuilderState> formKey,
  })
      : _formKey = formKey,
        super(key: key);

  final GlobalKey<FormBuilderState> _formKey;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(60.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset("assets/logo.png"),
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
              FormBuilderTextField(
                name: "email",
                // initialValue: kDebugMode ? "sandysultan@gmail.com" : "",
                // initialValue: kDebugMode ? "emilda.rika@gmail.com" : "",
                initialValue: kDebugMode ? "dianrosadi2020@gmail.com" : "",
                style: const TextStyle(color: Colors.white),
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
                style: const TextStyle(color: Colors.white),
                decoration:
                const InputDecoration(label: Text("Password")),
                obscureText: true,
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(
                height: 16,
              ),
              BlocListener<LoginCubit, LoginState>(
                listener: (context, state) async {
                  if (state is LoginLoading) {
                    EasyLoading.show(status: state.message);
                  } else if (state is LoginFailed) {
                    EasyLoading.showError(state.failedMessage);
                  } else if (state is LoginSuccess) {
                    EasyLoading.showSuccess('Login Success');
                    // await context.read<LocalRepository>().createLocal(state.email,state.token,s);
                    // FirebaseAuth.instance.idTokenChanges().listen((event) {
                    //   var logger = Logger();
                    //   if(event?.refreshToken?.isNotEmpty==true) {
                    //     logger.d('token:' + (event?.refreshToken??""));
                    //     context.read<LocalRepository>().updateToken(event!.refreshToken!);
                    //   }else{
                    //     event?.getIdToken().then((value) {
                    //       logger.d('token:' + value);
                    //       context.read<LocalRepository>().updateToken(value);
                    //     });
                    //   }
                    // });
                    Navigator.of(context).pushAndRemoveUntil<void>(
                      HomePage.route(),
                          (route) => false,
                    );
                  }
                },
                child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ==
                          true) {
                        context
                            .read<LoginCubit>()
                            .login(_formKey.currentState!.value['email'],_formKey.currentState!.value['password']);
                      }
                    },
                    child: const Text("Login")),
              ),
              // const SizedBox(
              //   height: 16,
              // ),
              // TextButton(
              //     onPressed: () {
              //       showDialog(
              //           context: context,
              //           builder: (_) => AlertDialog(
              //                 title: const Text("Forgot Password"),
              //                 content: FormBuilder(
              //                     key: _formKey,
              //                     child: FormBuilderTextField(
              //                       name: "email",
              //                       decoration: const InputDecoration(label: Text("Email")),
              //                       validator: FormBuilderValidators.compose([
              //                         FormBuilderValidators.email(context),
              //                         FormBuilderValidators.required(context)
              //                       ]),
              //                     )),
              //                 actions: [
              //                   TextButton(
              //                     child: const Text("Cancel"),
              //                     onPressed: () {
              //                       Navigator.of(context).pop();
              //                     },
              //                   ),
              //                   TextButton(
              //                     child: const Text("Submit"),
              //                     onPressed: () {
              //                       if(_formKey.currentState?.saveAndValidate()==true){
              //
              //                         Navigator.of(context).pop();
              //                       }
              //                     },
              //                   ),
              //                 ],
              //               ));
              //     },
              //     child: const Text("Forgot Password"))
            ],
          ),
        ),
      ),
    );
  }
}
