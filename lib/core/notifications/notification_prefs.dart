import 'package:shared_preferences/shared_preferences.dart';

/// تفضيلات إشعارات المفتش — تُحفظ محلياً لتطبيقها حتى والتطبيق مغلق.
class NotificationPrefs {
  NotificationPrefs._();

  static const newTasksKey = 'inspector_notify_new_tasks';
  static const reportApprovalsKey = 'inspector_notify_report_approvals';
  static const deadlineRemindersKey = 'inspector_notify_deadline';

  static const categoryNewTask = 'new_task';
  static const categoryReportApproval = 'report_approval';
  static const categoryDeadline = 'deadline';
  static const categoryPassword = 'password';
  static const categoryGeneral = 'general';

  static Future<void> save({
    required bool newTasks,
    required bool reportApprovals,
    required bool deadlineReminders,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(newTasksKey, newTasks);
    await prefs.setBool(reportApprovalsKey, reportApprovals);
    await prefs.setBool(deadlineRemindersKey, deadlineReminders);
  }

  static Future<bool> get newTasks async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(newTasksKey) ?? true;
  }

  static Future<bool> get reportApprovals async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(reportApprovalsKey) ?? true;
  }

  static Future<bool> get deadlineReminders async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(deadlineRemindersKey) ?? true;
  }

  /// هل يُسمح بعرض إشعار من هذه الفئة؟
  static Future<bool> allowsCategory(String? category) async {
    final key = (category ?? '').trim().toLowerCase();
    if (key.isEmpty ||
        key == categoryGeneral ||
        key == categoryPassword ||
        key == 'inspector_notification') {
      return true;
    }

    final prefs = await SharedPreferences.getInstance();
    switch (key) {
      case categoryNewTask:
      case 'newtask':
      case 'task':
        return prefs.getBool(newTasksKey) ?? true;
      case categoryReportApproval:
      case 'report':
      case 'approval':
      case 'reject':
        return prefs.getBool(reportApprovalsKey) ?? true;
      case categoryDeadline:
      case 'reminder':
        return prefs.getBool(deadlineRemindersKey) ?? true;
      default:
        return true;
    }
  }
}
