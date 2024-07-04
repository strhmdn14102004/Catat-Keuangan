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
      return android;
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


  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCytHti8p3N6L5qPktB5Gnj7caZSTwATww',
    appId: '1:789661885548:android:ff4f263cdb128e67a5a449',
    messagingSenderId: '789661885548',
    projectId: 'sunmolor-team',
    authDomain: 'sunmolor-team.firebaseapp.com',
    storageBucket: 'gs://sunmolor-team.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCytHti8p3N6L5qPktB5Gnj7caZSTwATww',
    appId: '1:789661885548:android:ff4f263cdb128e67a5a449',
    messagingSenderId: '789661885548',
    projectId: 'sunmolor-team',
    authDomain: 'sunmolor-team.firebaseapp.com',
    storageBucket: 'gs://sunmolor-team.appspot.com',
    iosClientId: '1045475764615-sh6bdtfvq5gi9hdi9elu247v7usqsvpl.apps.googleusercontent.com',
    iosBundleId: 'com.mrezys',
  );
}
