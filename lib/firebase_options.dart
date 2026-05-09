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
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBMvn7wNCzZcYr1uAjJYkiJ2CaIHAZln7k',
    appId: '1:859608128667:web:3ddee8582465e710b47a3e',
    messagingSenderId: '859608128667',
    projectId: 'nustdb',
    authDomain: 'nustdb.firebaseapp.com',
    storageBucket: 'nustdb.firebasestorage.app',
    measurementId: 'G-2R20604BG1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDUEVkiFOicls_4esCcm_62Y67E6mYBP8Q',
    appId: '1:859608128667:android:c0dd91651d414f5db47a3e',
    messagingSenderId: '859608128667',
    projectId: 'nustdb',
    storageBucket: 'nustdb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA1eh0_83wbvmGLkTxHuaWB2wOY0f525p4',
    appId: '1:859608128667:ios:6c1e043c22d623abb47a3e',
    messagingSenderId: '859608128667',
    projectId: 'nustdb',
    storageBucket: 'nustdb.firebasestorage.app',
    iosBundleId: 'com.thefabone.nustcampushealthapp',
  );
}
