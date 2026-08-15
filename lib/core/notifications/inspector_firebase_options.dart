import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase الخاص بتطبيق المفتش فقط — مشروع waqf-inspector-app.
class InspectorFirebaseOptions {
  static const String appName = 'WaqfInspector';
  static const String projectId = 'waqf-inspector-app';
  static const String messagingSenderId = '341619111653';
  static const String storageBucket = 'waqf-inspector-app.firebasestorage.app';

  static bool get isConfigured => true;

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwR1f8YW5x-EMEv4i3mVXzTEcIxI5sJYI',
    appId: '1:341619111653:android:e9bc67d3081562164fc60c',
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBef7fNrYq2unYu5YoXDLMD6hAweMAnf5E',
    appId: '1:341619111653:ios:a096d218d5b2fcbb4fc60c',
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: 'com.example.inspectorApp',
  );
}
