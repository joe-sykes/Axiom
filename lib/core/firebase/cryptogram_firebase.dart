import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for Cryptogram (cryptogram-1c5aa project)
class CryptogramFirebaseOptions {
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
          'CryptogramFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'CryptogramFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCovRS7cvN0OLRvwHSljmz1YCcSm0eTXR0',
    appId: '1:284222925831:web:606d61e998abd4768d0ea2',
    messagingSenderId: '284222925831',
    projectId: 'cryptogram-1c5aa',
    authDomain: 'cryptogram-1c5aa.firebaseapp.com',
    storageBucket: 'cryptogram-1c5aa.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCovRS7cvN0OLRvwHSljmz1YCcSm0eTXR0',
    appId: '1:284222925831:web:606d61e998abd4768d0ea2',
    messagingSenderId: '284222925831',
    projectId: 'cryptogram-1c5aa',
    storageBucket: 'cryptogram-1c5aa.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCovRS7cvN0OLRvwHSljmz1YCcSm0eTXR0',
    appId: '1:284222925831:web:606d61e998abd4768d0ea2',
    messagingSenderId: '284222925831',
    projectId: 'cryptogram-1c5aa',
    storageBucket: 'cryptogram-1c5aa.firebasestorage.app',
    iosBundleId: 'com.example.cryptogram',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCovRS7cvN0OLRvwHSljmz1YCcSm0eTXR0',
    appId: '1:284222925831:web:606d61e998abd4768d0ea2',
    messagingSenderId: '284222925831',
    projectId: 'cryptogram-1c5aa',
    storageBucket: 'cryptogram-1c5aa.firebasestorage.app',
    iosBundleId: 'com.example.cryptogram',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCovRS7cvN0OLRvwHSljmz1YCcSm0eTXR0',
    appId: '1:284222925831:web:606d61e998abd4768d0ea2',
    messagingSenderId: '284222925831',
    projectId: 'cryptogram-1c5aa',
    storageBucket: 'cryptogram-1c5aa.firebasestorage.app',
  );
}
