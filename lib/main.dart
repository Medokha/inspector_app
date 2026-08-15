import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:inspector_app/app/app.dart';
import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/notifications/inspector_realtime_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase مبكراً حتى تعمل الإشعارات والتطبيق مغلق.
  await ensureInspectorFirebase();
  FirebaseMessaging.onBackgroundMessage(inspectorFirebaseBackgroundHandler);
  await ensureInspectorNotificationChannel();

  await restoreSession();
  if (currentAuthSession().isAuthenticated) {
    unawaited(startInspectorRealtime());
    unawaited(startFieldSync());
  }

  runApp(const App());
}
