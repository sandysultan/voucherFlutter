import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:iVoucher/home/home.dart';
import 'package:iVoucher/login/login.dart';
import 'package:local_repository/local_repository.dart';

import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getToken();
  if (kDebugMode && !kIsWeb) {
    // Force disable Crashlytics collection while doing every day development.
    // Temporarily toggle this to true if you want to test crash reporting in your app.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
  // final storage = await HydratedStorage.build(
  //   storageDirectory: await getApplicationDocumentsDirectory(),
  // );
  // HydratedBlocOverrides.runZoned(
  //       () => runApp(const MyApp()),
  //   storage: storage,
  // );
  await LocalRepository.init();
  await createNotificationChannel();
  runApp(const MyApp());
}

createNotificationChannel() async {
  Map<String, AndroidNotificationChannel> channelMap = {
    'transfer': const AndroidNotificationChannel(
      'transfer',
      'Transfer',
      description: 'Transfer from finance to group bank account',
      importance: Importance.max,
    ),
    'sales': const AndroidNotificationChannel(
      'sales',
      'Sales',
      description: 'Sales from operator billing',
      importance: Importance.defaultImportance,
    ),
    'expense': const AndroidNotificationChannel(
      'expense',
      'Expense',
      description: 'Expenses report created by admin',
      importance: Importance.max,
    ),
    'fundRequest': const AndroidNotificationChannel(
      'fundRequest',
      'Fund Request',
      description: 'Fund requested by finance',
      importance: Importance.max,
    ),
    'closing': const AndroidNotificationChannel(
      'closing',
      'Closing Month',
      description: 'Closing month by admin',
      importance: Importance.max,
    ),
  };

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  channelMap.forEach((key, value) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(value);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              android.channelId ?? "",
              channelMap['android.channelId ?? ""']?.name??"",
              channelDescription: channelMap['android.channelId ?? ""']?.description??"",
              icon: android.smallIcon,
              // other properties...
            ),
          ));
    }
  });
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
            darkTheme: ThemeData(brightness: Brightness.dark),
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
                ? const HomePage()
                : const LoginPage()),
      ),
    );
  }
}
