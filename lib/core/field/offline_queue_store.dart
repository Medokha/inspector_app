import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum OfflineQueueKind { routePoint, report, taskCache }

/// عنصر في طابور المزامنة دون اتصال.
class OfflineQueueItem {
  OfflineQueueItem({
    required this.id,
    required this.kind,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
  });

  final String id;
  final OfflineQueueKind kind;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  int attempts;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'kind': kind.name,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'attempts': attempts,
      };

  factory OfflineQueueItem.fromJson(Map<String, dynamic> json) {
    return OfflineQueueItem(
      id: json['id'] as String,
      kind: OfflineQueueKind.values.firstWhere(
        (k) => k.name == json['kind'],
        orElse: () => OfflineQueueKind.routePoint,
      ),
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    );
  }
}

/// حفظ محلي لطابور المزامنة (مسار / تقارير / مهام).
class OfflineQueueStore {
  OfflineQueueStore._();

  static const _queueKey = 'inspector_offline_queue_v1';
  static const _tasksCacheKey = 'inspector_tasks_cache_v1';

  static Future<List<OfflineQueueItem>> loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) return <OfflineQueueItem>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map>()
          .map((e) => OfflineQueueItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return <OfflineQueueItem>[];
    }
  }

  static Future<void> _saveQueue(List<OfflineQueueItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _queueKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> enqueue(OfflineQueueItem item) async {
    final items = await loadQueue();
    items.add(item);
    await _saveQueue(items);
  }

  static Future<void> enqueueRoutePoint({
    required String taskId,
    required double latitude,
    required double longitude,
  }) {
    return enqueue(
      OfflineQueueItem(
        id: 'rp_${DateTime.now().microsecondsSinceEpoch}',
        kind: OfflineQueueKind.routePoint,
        payload: <String, dynamic>{
          'taskId': taskId,
          'latitude': latitude,
          'longitude': longitude,
        },
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  static Future<void> enqueueReport({
    required String taskId,
    required Map<String, dynamic> report,
  }) {
    return enqueue(
      OfflineQueueItem(
        id: 'rpt_${DateTime.now().microsecondsSinceEpoch}',
        kind: OfflineQueueKind.report,
        payload: <String, dynamic>{
          'taskId': taskId,
          ...report,
        },
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  static Future<void> remove(String id) async {
    final items = await loadQueue();
    items.removeWhere((e) => e.id == id);
    await _saveQueue(items);
  }

  static Future<void> bumpAttempt(String id) async {
    final items = await loadQueue();
    for (final item in items) {
      if (item.id == id) item.attempts += 1;
    }
    await _saveQueue(items);
  }

  static Future<int> pendingCount() async => (await loadQueue()).length;

  /// تخزين مؤقت لقائمة المهام للعرض دون اتصال.
  static Future<void> cacheTasksJson(List<Map<String, dynamic>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksCacheKey, jsonEncode(tasks));
  }

  static Future<List<Map<String, dynamic>>> loadCachedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksCacheKey);
    if (raw == null || raw.isEmpty) return const <Map<String, dynamic>>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }
}
