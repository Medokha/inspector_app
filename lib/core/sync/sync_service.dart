import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:inspector_app/core/database/database_service.dart';
import 'package:inspector_app/features/tasks/data/datasources/tasks_remote_data_source.dart';

class SyncService {
  SyncService(this._db, this._remote);

  final DatabaseService _db;
  final TasksRemoteDataSource _remote;
  bool _isSyncing = false;

  void init() {
    Connectivity().onConnectivityChanged.listen((results) {
      // Check if any of the results indicate we have internet
      final hasInternet = results.any((result) => result != ConnectivityResult.none);
      if (hasInternet) {
        syncPendingReports();
      }
    });
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
          // 1. Upload Report Data
          await _remote.submitReport(
            taskId,
            {
              'generalCondition': report['generalCondition'],
              'qualityScore': report['qualityScore'],
              'hasViolations': report['hasViolations'] == 1,
              'reportNotes': report['reportNotes'],
            },
          );

          // 2. Upload Photos if any
          final List<String> photoPaths = (jsonDecode(report['photoPaths'] as String) as List).cast<String>();
          for (final path in photoPaths) {
            final file = File(path);
            if (await file.exists()) {
              await _remote.uploadMedia(taskId, file);
            }
          }

          // 3. Mark as synced
          await _db.markAsSynced(id);
          print('Synced report for task $taskId');
        } catch (e) {
          print('Failed to sync report $id: $e');
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
