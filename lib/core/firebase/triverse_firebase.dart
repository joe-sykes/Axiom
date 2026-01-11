import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for Triverse (triverse-5a5b7 project)
class TriverseFirebaseOptions {
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
          'TriverseFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'TriverseFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC_wd-_sAIrnFRLu8zh_VFevgihP357HMI',
    appId: '1:1002978058528:web:45f1d883fb8e0494523745',
    messagingSenderId: '1002978058528',
    projectId: 'triverse-5a5b7',
    authDomain: 'triverse-5a5b7.firebaseapp.com',
    storageBucket: 'triverse-5a5b7.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_wd-_sAIrnFRLu8zh_VFevgihP357HMI',
    appId: '1:1002978058528:web:45f1d883fb8e0494523745',
    messagingSenderId: '1002978058528',
    projectId: 'triverse-5a5b7',
    storageBucket: 'triverse-5a5b7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC_wd-_sAIrnFRLu8zh_VFevgihP357HMI',
    appId: '1:1002978058528:web:45f1d883fb8e0494523745',
    messagingSenderId: '1002978058528',
    projectId: 'triverse-5a5b7',
    storageBucket: 'triverse-5a5b7.firebasestorage.app',
    iosBundleId: 'com.example.triverse',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC_wd-_sAIrnFRLu8zh_VFevgihP357HMI',
    appId: '1:1002978058528:web:45f1d883fb8e0494523745',
    messagingSenderId: '1002978058528',
    projectId: 'triverse-5a5b7',
    storageBucket: 'triverse-5a5b7.firebasestorage.app',
    iosBundleId: 'com.example.triverse',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC_wd-_sAIrnFRLu8zh_VFevgihP357HMI',
    appId: '1:1002978058528:web:45f1d883fb8e0494523745',
    messagingSenderId: '1002978058528',
    projectId: 'triverse-5a5b7',
    storageBucket: 'triverse-5a5b7.firebasestorage.app',
  );
}
