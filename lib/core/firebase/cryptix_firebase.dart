import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for Cryptix (cryptix-fbddb project)
class CryptixFirebaseOptions {
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
          'CryptixFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'CryptixFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAg05cVMsyqYdfVCKrTAX1g7cw975-wMnc',
    appId: '1:272211834450:web:c7b206cd09e2ecfe36d18b',
    messagingSenderId: '272211834450',
    projectId: 'cryptix-fbddb',
    authDomain: 'cryptix-fbddb.firebaseapp.com',
    storageBucket: 'cryptix-fbddb.firebasestorage.app',
    measurementId: 'G-2QMF9X7LGY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAg05cVMsyqYdfVCKrTAX1g7cw975-wMnc',
    appId: '1:272211834450:web:c7b206cd09e2ecfe36d18b',
    messagingSenderId: '272211834450',
    projectId: 'cryptix-fbddb',
    storageBucket: 'cryptix-fbddb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAg05cVMsyqYdfVCKrTAX1g7cw975-wMnc',
    appId: '1:272211834450:web:c7b206cd09e2ecfe36d18b',
    messagingSenderId: '272211834450',
    projectId: 'cryptix-fbddb',
    storageBucket: 'cryptix-fbddb.firebasestorage.app',
    iosBundleId: 'com.example.cryptix',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAg05cVMsyqYdfVCKrTAX1g7cw975-wMnc',
    appId: '1:272211834450:web:c7b206cd09e2ecfe36d18b',
    messagingSenderId: '272211834450',
    projectId: 'cryptix-fbddb',
    storageBucket: 'cryptix-fbddb.firebasestorage.app',
    iosBundleId: 'com.example.cryptix',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAg05cVMsyqYdfVCKrTAX1g7cw975-wMnc',
    appId: '1:272211834450:web:c7b206cd09e2ecfe36d18b',
    messagingSenderId: '272211834450',
    projectId: 'cryptix-fbddb',
    storageBucket: 'cryptix-fbddb.firebasestorage.app',
  );
}
