import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:inspector_app/core/field/field_sync_service.dart';
import 'package:inspector_app/core/field/offline_queue_store.dart';
import 'package:inspector_app/features/tasks/data/services/inspector_tracking_service.dart';
import 'package:inspector_app/features/tasks/domain/quality/report_quality_service.dart';
import 'package:inspector_app/features/tasks/domain/quality/report_templates.dart';
import 'package:inspector_app/features/tasks/domain/quality/voice_note_service.dart';
import 'package:inspector_app/features/tasks/domain/usecases/submit_task_report_usecase.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ReportController extends ChangeNotifier {
  ReportController({
    required SubmitTaskReportUseCase submitReport,
    required InspectorTrackingService tracking,
    FieldSyncService? sync,
  })  : _submitReport = submitReport,
        _tracking = tracking,
        _sync = sync;

  final SubmitTaskReportUseCase _submitReport;
  final InspectorTrackingService _tracking;
  final FieldSyncService? _sync;

  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<bool> submit({
    required String taskId,
    required String generalCondition,
    required int qualityScore,
    required bool hasViolations,
    String? reportNotes,
    List<String> photoPaths = const <String>[],
    List<({List<int> bytes, String filename})> photoFiles =
        const <({List<int> bytes, String filename})>[],
    ChecklistState? checklist,
    ReportTemplate? template,
    Map<String, String> templateFields = const <String, String>{},
    VoiceNoteMeta? voiceNote,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      if (checklist != null) {
        final validation = ReportQualityService.validateBeforeSubmit(
          checklist: checklist,
          attachmentCount: photoFiles.length + photoPaths.length + (voiceNote != null ? 1 : 0),
          voiceNote: voiceNote,
        );
        if (validation != null) {
          _error = validation;
          return false;
        }
      }

      final notes = template == null
          ? reportNotes
          : ReportQualityService.composeNotesFromTemplate(
              template: template,
              fieldValues: templateFields,
              extraNotes: reportNotes,
              voiceNote: voiceNote,
            );

      final sync = _sync;
      final online = sync == null ? true : await sync.isOnline;
      if (!online) {
        final savedPaths = await _persistAttachmentsOffline(
          taskId: taskId,
          photoFiles: photoFiles,
          voiceNote: voiceNote,
        );
        await OfflineQueueStore.enqueueReport(
          taskId: taskId,
          report: <String, dynamic>{
            'generalCondition': generalCondition,
            'qualityScore': qualityScore,
            'hasViolations': hasViolations,
            'reportNotes': notes,
            'photoPaths': savedPaths,
            if (voiceNote != null) 'audioPath': await VoiceNoteService.persistForOffline(
              voiceNote.filePath,
              taskId: taskId,
            ),
          },
        );
        await sync.refreshPendingCount();
        await _tracking.stop();
        return true;
      }

      final files = <({List<int> bytes, String filename})>[...photoFiles];
      if (voiceNote != null) {
        final bytes = await File(voiceNote.filePath).readAsBytes();
        files.add((bytes: bytes, filename: voiceNote.filename));
      }

      await _submitReport(
        taskId: taskId,
        generalCondition: generalCondition,
        qualityScore: qualityScore,
        hasViolations: hasViolations,
        reportNotes: notes,
        photoPaths: photoPaths,
        photoFiles: files,
      );
      await _tracking.stop();
      return true;
    } catch (e) {
      // فشل الشبكة → طابور عدم الاتصال
      try {
        final savedPaths = await _persistAttachmentsOffline(
          taskId: taskId,
          photoFiles: photoFiles,
          voiceNote: voiceNote,
        );
        await OfflineQueueStore.enqueueReport(
          taskId: taskId,
          report: <String, dynamic>{
            'generalCondition': generalCondition,
            'qualityScore': qualityScore,
            'hasViolations': hasViolations,
            'reportNotes': reportNotes,
            'photoPaths': savedPaths,
          },
        );
        await _sync?.refreshPendingCount();
        await _tracking.stop();
        return true;
      } catch (_) {
        _error = e.toString();
        return false;
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<List<String>> _persistAttachmentsOffline({
    required String taskId,
    required List<({List<int> bytes, String filename})> photoFiles,
    VoiceNoteMeta? voiceNote,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final outDir = Directory(p.join(dir.path, 'offline_reports', taskId));
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }
    final paths = <String>[];
    for (var i = 0; i < photoFiles.length; i++) {
      final file = photoFiles[i];
      final path = p.join(outDir.path, '${DateTime.now().millisecondsSinceEpoch}_$i${p.extension(file.filename)}');
      await File(path).writeAsBytes(file.bytes);
      paths.add(path);
    }
    return paths;
  }
}
