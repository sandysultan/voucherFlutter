import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/login_cubit.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

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
          FormBuilder(
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
                      decoration: const InputDecoration(label: Text("Email")),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.email(context),
                        FormBuilderValidators.required(context)
                      ]),
                    ),
                    FormBuilderTextField(
                      name: "password",
                      decoration:
                          const InputDecoration(label: Text("Password")),
                      obscureText: true,
                      validator: FormBuilderValidators.required(context),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    BlocListener<LoginCubit, LoginState>(
                      listener: (context, state) {
                        // TODO: implement listener
                      },
                      child: TextButton(
                          onPressed: () {
                            //todo
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
          ),
        ],
      ),
    );
  }
}
