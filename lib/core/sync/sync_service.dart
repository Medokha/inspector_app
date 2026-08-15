import 'dart:convert';
import 'dart:io';

import 'package:inspector_app/core/database/database_service.dart';
import 'package:inspector_app/features/tasks/data/datasources/tasks_remote_data_source.dart';

/// مزامنة بسيطة عند الطلب — بدون اعتماد على connectivity_plus.
class SyncService {
  SyncService(this._db, this._remote);

  final DatabaseService _db;
  final TasksRemoteDataSource _remote;
  bool _isSyncing = false;

  void init() {
    // لا يوجد مستمع شبكة هنا؛ يمكن استدعاء syncPendingReports يدوياً.
  }

  Future<void> syncPendingReports() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final reports = await _db.getUnsyncedReports();
      for (final report in reports) {
        final id = report['id'] as int;
        final taskId = report['taskId'] as String;

        try {
          await _remote.submitReport(
            taskId,
            <String, dynamic>{
              'generalCondition': report['generalCondition'],
              'qualityScore': report['qualityScore'],
              'hasViolations': report['hasViolations'] == 1,
              'reportNotes': report['reportNotes'],
            },
          );

          final photoPathsRaw = report['photoPaths'];
          final List<String> photoPaths = photoPathsRaw is String
              ? (jsonDecode(photoPathsRaw) as List).cast<String>()
              : const <String>[];
          for (final path in photoPaths) {
            final file = File(path);
            if (await file.exists()) {
              await _remote.uploadMedia(taskId, file);
            }
          }

          await _db.markAsSynced(id);
        } catch (_) {}
      }
    } finally {
      _isSyncing = false;
    }
  }
}
