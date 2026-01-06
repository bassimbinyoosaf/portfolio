// Manually created Firebase options (web-only).
// This file provides the FirebaseOptions for web (from your firebaseConfig).
// On mobile platforms call Firebase.initializeApp() without options (or add mobile options here).
//
// Usage:
// import 'firebase_options.dart';
// if (kIsWeb) await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
// else await Firebase.initializeApp();

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for web. '
      'On mobile platforms call Firebase.initializeApp() without options '
      'or add Mobile FirebaseOptions to this file.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB8qs7fUxZxqfn3HmRNhGS6ZWRF7rsdwaE',
    authDomain: 'portfolio-e560d.firebaseapp.com',
    projectId: 'portfolio-e560d',
    storageBucket: 'portfolio-e560d.firebasestorage.app',
    messagingSenderId: '479372401564',
    appId: '1:479372401564:web:92de56b40b639d0925c659',
    measurementId: 'G-4SDEDLGYC7',
  );
}