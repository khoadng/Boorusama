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
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD3-XOi67wpNOjGlpinywLq9yZONCsI8PM',
    appId: '1:528031364467:web:e372c0bb9fe2ff85200106',
    messagingSenderId: '528031364467',
    projectId: 'boorusama-63527',
    authDomain: 'boorusama-63527.firebaseapp.com',
    storageBucket: 'boorusama-63527.appspot.com',
    measurementId: 'G-CS6PSRNNDF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCKxLz-56wm7r4l7wxAn0vzaBeP0SxXov0',
    appId: '1:528031364467:android:e7221d19ac2bd3dd200106',
    messagingSenderId: '528031364467',
    projectId: 'boorusama-63527',
    storageBucket: 'boorusama-63527.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCN-WNXXCeIlfzrmQIRCbWz82wnggSi5WA',
    appId: '1:528031364467:ios:ccf691fc1483c6c4200106',
    messagingSenderId: '528031364467',
    projectId: 'boorusama-63527',
    storageBucket: 'boorusama-63527.appspot.com',
    iosClientId: '528031364467-1421e254f6kv80eugt3ptdq8kk0mo27o.apps.googleusercontent.com',
    iosBundleId: 'com.degenk.boorusama',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCN-WNXXCeIlfzrmQIRCbWz82wnggSi5WA',
    appId: '1:528031364467:ios:ccf691fc1483c6c4200106',
    messagingSenderId: '528031364467',
    projectId: 'boorusama-63527',
    storageBucket: 'boorusama-63527.appspot.com',
    iosClientId: '528031364467-1421e254f6kv80eugt3ptdq8kk0mo27o.apps.googleusercontent.com',
    iosBundleId: 'com.degenk.boorusama',
  );
}
