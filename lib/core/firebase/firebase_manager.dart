import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'almanac_firebase.dart';
import 'cryptix_firebase.dart';
import 'cryptogram_firebase.dart';
import 'doublet_firebase.dart';
import 'triverse_firebase.dart';

/// Manages multiple Firebase projects for the Axiom app.
/// Each game (Almanac, Cryptix, Doublet, Triverse, Cryptogram) has its own Firebase project.
/// Firebase apps are lazily initialized when first accessed to improve startup performance.
class FirebaseManager {
  static FirebaseApp? _almanacApp;
  static FirebaseApp? _cryptixApp;
  static FirebaseApp? _cryptogramApp;
  static FirebaseApp? _doubletApp;
  static FirebaseApp? _triverseApp;

  static bool _defaultInitialized = false;

  /// Initialize the default Firebase app (required before any secondary apps)
  static Future<void> _ensureDefaultInitialized() async {
    if (_defaultInitialized) return;
    await Firebase.initializeApp(
      options: AlmanacFirebaseOptions.currentPlatform,
    );
    _almanacApp = Firebase.app();
    _defaultInitialized = true;
  }

  /// Ensure Almanac Firebase is initialized
  static Future<void> ensureAlmanacInitialized() async {
    if (_almanacApp != null) return;
    await _ensureDefaultInitialized();
  }

  /// Ensure Cryptix Firebase is initialized
  static Future<void> ensureCryptixInitialized() async {
    if (_cryptixApp != null) return;
    await _ensureDefaultInitialized();
    _cryptixApp = await Firebase.initializeApp(
      name: 'cryptix',
      options: CryptixFirebaseOptions.currentPlatform,
    );
  }

  /// Ensure Doublet Firebase is initialized
  static Future<void> ensureDoubletInitialized() async {
    if (_doubletApp != null) return;
    await _ensureDefaultInitialized();
    _doubletApp = await Firebase.initializeApp(
      name: 'doublet',
      options: DoubletFirebaseOptions.currentPlatform,
    );
  }

  /// Ensure Triverse Firebase is initialized
  static Future<void> ensureTriverseInitialized() async {
    if (_triverseApp != null) return;
    await _ensureDefaultInitialized();
    _triverseApp = await Firebase.initializeApp(
      name: 'triverse',
      options: TriverseFirebaseOptions.currentPlatform,
    );
  }

  /// Ensure Cryptogram Firebase is initialized
  static Future<void> ensureCryptogramInitialized() async {
    if (_cryptogramApp != null) return;
    await _ensureDefaultInitialized();
    _cryptogramApp = await Firebase.initializeApp(
      name: 'cryptogram',
      options: CryptogramFirebaseOptions.currentPlatform,
    );
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
