import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';

class SubmitTaskReportUseCase {
  const SubmitTaskReportUseCase(this._repository);

  final TasksRepository _repository;

  Future<void> call({
    required String taskId,
    required String generalCondition,
    required int qualityScore,
    required bool hasViolations,
    String? reportNotes,
    List<String> photoPaths = const <String>[],
    List<({List<int> bytes, String filename})> photoFiles = const <({List<int> bytes, String filename})>[],
  }) {
    return _repository.submitReport(
      taskId: taskId,
      generalCondition: generalCondition,
      qualityScore: qualityScore,
      hasViolations: hasViolations,
      reportNotes: reportNotes,
      photoPaths: photoPaths,
      photoFiles: photoFiles,
    );
  }
}
