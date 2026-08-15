import 'package:flutter/material.dart';
import 'package:inspector_app/features/tasks/presentation/pages/task_details_page.dart';

/// اختصارات سريعة من الإشعار: فتح المهمة أو بدء التتبع.
class NotificationNavigation {
  NotificationNavigation._();

  static GlobalKey<NavigatorState>? navigatorKey;

  static void bind(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  /// payload بصيغة: `taskId` أو `taskId|start`
  static Future<void> handlePayload(String? payload) async {
    if (payload == null || payload.trim().isEmpty) return;
    final parts = payload.split('|');
    final taskId = parts.first.trim();
    if (taskId.isEmpty) return;
    final startTracking = parts.length > 1 && parts[1].toLowerCase() == 'start';

    final nav = navigatorKey?.currentState;
    if (nav == null) return;

    await nav.push(
      MaterialPageRoute(
        builder: (_) => TaskDetailsPage(
          taskId: taskId,
          autoStartTracking: startTracking,
        ),
      ),
    );
  }
}
