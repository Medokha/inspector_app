import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:inspector_app/core/database/database_service.dart';
import 'package:inspector_app/core/sync/sync_service.dart';

class ReportController extends ChangeNotifier {
  ReportController({
    required this.taskId,
    required DatabaseService db,
    required SyncService syncService,
  }) : _db = db, _syncService = syncService;

  final String taskId;
  final DatabaseService _db;
  final SyncService _syncService;
  
  String _generalCondition = 'good';
  int _qualityScore = 75;
  bool _hasViolations = false;
  String _notes = '';
  final List<String> _photoPaths = [];
  bool _isSubmitting = false;

  String get generalCondition => _generalCondition;
  int get qualityScore => _qualityScore;
  bool get hasViolations => _hasViolations;
  String get notes => _notes;
  List<String> get photoPaths => _photoPaths;
  bool get isSubmitting => _isSubmitting;

  void setCondition(String value) {
    _generalCondition = value;
    notifyListeners();
  }

  void setScore(int value) {
    _qualityScore = value;
    notifyListeners();
  }

  void setViolations(bool value) {
    _hasViolations = value;
    notifyListeners();
  }

  void setNotes(String value) {
    _notes = value;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _photoPaths.add(image.path);
      notifyListeners();
    }
  }

  Future<void> submit() async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final reportData = {
        'taskId': taskId,
        'generalCondition': _generalCondition,
        'qualityScore': _qualityScore,
        'hasViolations': _hasViolations ? 1 : 0,
        'reportNotes': _notes,
        'photoPaths': jsonEncode(_photoPaths),
        'createdAt': DateTime.now().toIso8601String(),
        'isSynced': 0,
      };

      // Save to local database
      await _db.saveReport(reportData);

      // Try to sync immediately
      _syncService.syncPendingReports();
      
    } catch (e) {
      debugPrint('Error saving report: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
