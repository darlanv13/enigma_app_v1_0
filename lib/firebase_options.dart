// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyBzpVXnHFoAj1j7RgMgRXo-DPER38B5yF4',
    appId: '1:666260329572:web:b859dbab43f8e968cdfb71',
    messagingSenderId: '666260329572',
    projectId: 'enigmaapp-d4fc4',
    authDomain: 'enigmaapp-d4fc4.firebaseapp.com',
    storageBucket: 'enigmaapp-d4fc4.appspot.com',
    measurementId: 'G-CLTYFVZJ09',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyArkTRNyqghLN5VZuGJGoOxkxndZCgo2wU',
    appId: '1:666260329572:android:26ad19a7af02808fcdfb71',
    messagingSenderId: '666260329572',
    projectId: 'enigmaapp-d4fc4',
    storageBucket: 'enigmaapp-d4fc4.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB67rm87hit-rUpH_8V9d6gP_d_6jtxiIg',
    appId: '1:666260329572:ios:c4a9b7137d9e3784cdfb71',
    messagingSenderId: '666260329572',
    projectId: 'enigmaapp-d4fc4',
    storageBucket: 'enigmaapp-d4fc4.appspot.com',
    iosBundleId: 'com.example.enigmaAppV10',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB67rm87hit-rUpH_8V9d6gP_d_6jtxiIg',
    appId: '1:666260329572:ios:c4a9b7137d9e3784cdfb71',
    messagingSenderId: '666260329572',
    projectId: 'enigmaapp-d4fc4',
    storageBucket: 'enigmaapp-d4fc4.appspot.com',
    iosBundleId: 'com.example.enigmaAppV10',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBzpVXnHFoAj1j7RgMgRXo-DPER38B5yF4',
    appId: '1:666260329572:web:026cbca16655da77cdfb71',
    messagingSenderId: '666260329572',
    projectId: 'enigmaapp-d4fc4',
    authDomain: 'enigmaapp-d4fc4.firebaseapp.com',
    storageBucket: 'enigmaapp-d4fc4.appspot.com',
    measurementId: 'G-60NN5BVF2R',
  );
}
