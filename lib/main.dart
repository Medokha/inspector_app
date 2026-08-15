import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:inspector_app/app/app.dart';
import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/notifications/inspector_firebase_options.dart';
import 'package:inspector_app/core/notifications/inspector_realtime_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(inspectorFirebaseBackgroundHandler);
  await restoreSession();
  runApp(const App());
}
