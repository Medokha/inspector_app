import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/tasks/data/services/inspector_tracking_service.dart';
import 'package:inspector_app/features/tasks/domain/usecases/submit_task_report_usecase.dart';

class ReportController extends ChangeNotifier {
  ReportController({
    required SubmitTaskReportUseCase submitReport,
    required InspectorTrackingService tracking,
  })  : _submitReport = submitReport,
        _tracking = tracking;

  final SubmitTaskReportUseCase _submitReport;
  final InspectorTrackingService _tracking;

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
    List<({List<int> bytes, String filename})> photoFiles = const <({List<int> bytes, String filename})>[],
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _submitReport(
        taskId: taskId,
        generalCondition: generalCondition,
        qualityScore: qualityScore,
        hasViolations: hasViolations,
        reportNotes: reportNotes,
        photoPaths: photoPaths,
        photoFiles: photoFiles,
      );
      _tracking.stop();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
