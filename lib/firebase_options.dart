import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
        return android;
      }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase configuration for this platform has not been generated yet. '
          'Run `flutterfire configure` and select the required platform.',
        );
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAO6YdLWm5DN2HvoL79Xicq9Ml0PkCkq2k',
    appId: '1:928931500188:android:ebcf882096f27d305a1d59',
    messagingSenderId: '928931500188',
    projectId: 'swipebuy-worldwide',
    storageBucket: 'swipebuy-worldwide.firebasestorage.app',
  );
}
