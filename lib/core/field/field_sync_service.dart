import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:inspector_app/core/field/offline_queue_store.dart';
import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';

/// يزامن طابور عدم الاتصال عند عودة الشبكة.
class FieldSyncService {
  FieldSyncService(this._repository);

  final TasksRepository _repository;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _syncing = false;

  final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);

  Future<void> start() async {
    await refreshPendingCount();
    await _sub?.cancel();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      if (_hasNetwork(results)) {
        unawaited(syncPending());
      }
    });
    // محاولة أولية
    final now = await Connectivity().checkConnectivity();
    if (_hasNetwork(now)) {
      unawaited(syncPending());
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  bool _hasNetwork(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<bool> get isOnline async {
    final results = await Connectivity().checkConnectivity();
    return _hasNetwork(results);
  }

  Future<void> refreshPendingCount() async {
    pendingCount.value = await OfflineQueueStore.pendingCount();
  }

  /// مزامنة كل العناصر المعلّقة (مسار + تقارير).
  Future<int> syncPending() async {
    if (_syncing) return 0;
    _syncing = true;
    var synced = 0;
    try {
      final items = await OfflineQueueStore.loadQueue();
      for (final item in items) {
        try {
          switch (item.kind) {
            case OfflineQueueKind.routePoint:
              await _syncRoutePoint(item);
              break;
            case OfflineQueueKind.report:
              await _syncReport(item);
              break;
            case OfflineQueueKind.taskCache:
              break;
          }
          await OfflineQueueStore.remove(item.id);
          synced++;
        } catch (e) {
          debugPrint('FieldSync item ${item.id} failed: $e');
          await OfflineQueueStore.bumpAttempt(item.id);
        }
      }
    } finally {
      _syncing = false;
      await refreshPendingCount();
    }
    return synced;
  }

  Future<void> _syncRoutePoint(OfflineQueueItem item) async {
    final p = item.payload;
    await _repository.updateLocation(
      latitude: (p['latitude'] as num).toDouble(),
      longitude: (p['longitude'] as num).toDouble(),
      taskId: p['taskId']?.toString(),
    );
  }

  Future<void> _syncReport(OfflineQueueItem item) async {
    final p = item.payload;
    final taskId = p['taskId']?.toString() ?? '';
    final photoPaths = (p['photoPaths'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final audioPath = p['audioPath']?.toString();

    final files = <({List<int> bytes, String filename})>[];
    for (final path in photoPaths) {
      final file = File(path);
      if (await file.exists()) {
        files.add((bytes: await file.readAsBytes(), filename: file.uri.pathSegments.last));
      }
    }
    if (audioPath != null && audioPath.isNotEmpty) {
      final audio = File(audioPath);
      if (await audio.exists()) {
        files.add((bytes: await audio.readAsBytes(), filename: audio.uri.pathSegments.last));
      }
    }

    await _repository.submitReport(
      taskId: taskId,
      generalCondition: p['generalCondition']?.toString() ?? '',
      qualityScore: (p['qualityScore'] as num?)?.toInt() ?? 3,
      hasViolations: p['hasViolations'] == true,
      reportNotes: p['reportNotes']?.toString(),
      photoFiles: files,
    );
  }
}
