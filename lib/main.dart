import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inspector_app/app/app.dart';
import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Note: This will fail if google-services.json is missing.
    await Firebase.initializeApp();
    await NotificationService().initialize();
    getSyncService(); // Start background sync listener
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const App());
}
