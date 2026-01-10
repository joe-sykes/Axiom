import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for Almanac (axiom-2f07d project)
class AlmanacFirebaseOptions {
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
          'AlmanacFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'AlmanacFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC76jR74q8MQVmd7xPsRCDN1pPQzyBIpnY',
    appId: '1:334322595710:web:a083104e954d763437a52f',
    messagingSenderId: '334322595710',
    projectId: 'axiom-2f07d',
    authDomain: 'axiom-2f07d.firebaseapp.com',
    storageBucket: 'axiom-2f07d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC76jR74q8MQVmd7xPsRCDN1pPQzyBIpnY',
    appId: '1:334322595710:web:a083104e954d763437a52f',
    messagingSenderId: '334322595710',
    projectId: 'axiom-2f07d',
    storageBucket: 'axiom-2f07d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC76jR74q8MQVmd7xPsRCDN1pPQzyBIpnY',
    appId: '1:334322595710:web:a083104e954d763437a52f',
    messagingSenderId: '334322595710',
    projectId: 'axiom-2f07d',
    storageBucket: 'axiom-2f07d.firebasestorage.app',
    iosBundleId: 'com.example.almanac',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC76jR74q8MQVmd7xPsRCDN1pPQzyBIpnY',
    appId: '1:334322595710:web:a083104e954d763437a52f',
    messagingSenderId: '334322595710',
    projectId: 'axiom-2f07d',
    storageBucket: 'axiom-2f07d.firebasestorage.app',
    iosBundleId: 'com.example.almanac',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC76jR74q8MQVmd7xPsRCDN1pPQzyBIpnY',
    appId: '1:334322595710:web:a083104e954d763437a52f',
    messagingSenderId: '334322595710',
    projectId: 'axiom-2f07d',
    storageBucket: 'axiom-2f07d.firebasestorage.app',
  );
}
