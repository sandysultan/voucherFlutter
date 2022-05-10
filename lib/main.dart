import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:local_repository/local_repository.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:voucher/home/home.dart';
import 'package:voucher/login/login.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    // Force disable Crashlytics collection while doing every day development.
    // Temporarily toggle this to true if you want to test crash reporting in your app.
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(false);
  }
  // final storage = await HydratedStorage.build(
  //   storageDirectory: await getApplicationDocumentsDirectory(),
  // );
  // HydratedBlocOverrides.runZoned(
  //       () => runApp(const MyApp()),
  //   storage: storage,
  // );
  await LocalRepository.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: RepositoryProvider(
        create: (context) => LocalRepository(),
        child: MaterialApp(
            supportedLocales: const [
              Locale('id'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              FormBuilderLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            title: 'I Voucher',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              primarySwatch: Colors.blue,
            ),
            builder: EasyLoading.init(),
            home: FirebaseAuth.instance.currentUser != null
                ? HomePage()
                : const LoginPage()
        ),
      ),
    );
  }
}

