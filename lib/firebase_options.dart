// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB0W7IOTLgR7bfnlN6rkK2D5GN9OJvk8G8',
    appId: '1:94374287489:web:9f4d9c4c70cef371abd580',
    messagingSenderId: '94374287489',
    projectId: 'voucher-3d35e',
    authDomain: 'voucher-3d35e.firebaseapp.com',
    storageBucket: 'voucher-3d35e.appspot.com',
    measurementId: 'G-2FEEZCDNC4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDIrGm5qU1CMg9BBxYIwxWXRlWsQyKzY4',
    appId: '1:94374287489:android:629aa1b060b91318abd580',
    messagingSenderId: '94374287489',
    projectId: 'voucher-3d35e',
    storageBucket: 'voucher-3d35e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIH2uwZMN2WEchwLECjWu9uywux3X3-cs',
    appId: '1:94374287489:ios:e6bde9b882879de3abd580',
    messagingSenderId: '94374287489',
    projectId: 'voucher-3d35e',
    storageBucket: 'voucher-3d35e.appspot.com',
    iosClientId: '94374287489-abdn3h91n6o06c1ikqlpsfm095ob8glg.apps.googleusercontent.com',
    iosBundleId: 'com.babystep.voucher',
  );
}
