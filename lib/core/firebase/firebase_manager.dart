import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'almanac_firebase.dart';
import 'cryptix_firebase.dart';
import 'cryptogram_firebase.dart';
import 'doublet_firebase.dart';
import 'triverse_firebase.dart';

/// Manages multiple Firebase projects for the Axiom app.
/// Each game (Almanac, Cryptix, Doublet, Triverse) has its own Firebase project.
class FirebaseManager {
  static FirebaseApp? _almanacApp;
  static FirebaseApp? _cryptixApp;
  static FirebaseApp? _cryptogramApp;
  static FirebaseApp? _doubletApp;
  static FirebaseApp? _triverseApp;

  static bool _initialized = false;

  /// Initialize all Firebase apps
  static Future<void> initializeAll() async {
    if (_initialized) return;

    // Initialize Almanac as the default app
    await Firebase.initializeApp(
      options: AlmanacFirebaseOptions.currentPlatform,
    );
    _almanacApp = Firebase.app();

    // Initialize Cryptix as a secondary app
    _cryptixApp = await Firebase.initializeApp(
      name: 'cryptix',
      options: CryptixFirebaseOptions.currentPlatform,
    );

    // Initialize Doublet as a secondary app
    _doubletApp = await Firebase.initializeApp(
      name: 'doublet',
      options: DoubletFirebaseOptions.currentPlatform,
    );

    // Initialize Triverse as a secondary app
    _triverseApp = await Firebase.initializeApp(
      name: 'triverse',
      options: TriverseFirebaseOptions.currentPlatform,
    );

    // Initialize Cryptogram as a secondary app
    _cryptogramApp = await Firebase.initializeApp(
      name: 'cryptogram',
      options: CryptogramFirebaseOptions.currentPlatform,
    );

    _initialized = true;
  }

  /// Get the Almanac Firebase app
  static FirebaseApp get almanacApp {
    if (_almanacApp == null) {
      throw StateError('FirebaseManager not initialized. Call initializeAll() first.');
    }
    return _almanacApp!;
  }

  /// Get the Cryptix Firebase app
  static FirebaseApp get cryptixApp {
    if (_cryptixApp == null) {
      throw StateError('FirebaseManager not initialized. Call initializeAll() first.');
    }
    return _cryptixApp!;
  }

  /// Get the Doublet Firebase app
  static FirebaseApp get doubletApp {
    if (_doubletApp == null) {
      throw StateError('FirebaseManager not initialized. Call initializeAll() first.');
    }
    return _doubletApp!;
  }

  /// Get Firestore instance for Almanac
  static FirebaseFirestore get almanacFirestore {
    return FirebaseFirestore.instanceFor(app: almanacApp);
  }

  /// Get Firestore instance for Cryptix
  static FirebaseFirestore get cryptixFirestore {
    return FirebaseFirestore.instanceFor(app: cryptixApp);
  }

  /// Get Firestore instance for Doublet
  static FirebaseFirestore get doubletFirestore {
    return FirebaseFirestore.instanceFor(app: doubletApp);
  }

  /// Get the Triverse Firebase app
  static FirebaseApp get triverseApp {
    if (_triverseApp == null) {
      throw StateError('FirebaseManager not initialized. Call initializeAll() first.');
    }
    return _triverseApp!;
  }

  /// Get Firestore instance for Triverse
  static FirebaseFirestore get triverseFirestore {
    return FirebaseFirestore.instanceFor(app: triverseApp);
  }

  /// Get the Cryptogram Firebase app
  static FirebaseApp get cryptogramApp {
    if (_cryptogramApp == null) {
      throw StateError('FirebaseManager not initialized. Call initializeAll() first.');
    }
    return _cryptogramApp!;
  }

  /// Get Firestore instance for Cryptogram
  static FirebaseFirestore get cryptogramFirestore {
    return FirebaseFirestore.instanceFor(app: cryptogramApp);
  }
}
