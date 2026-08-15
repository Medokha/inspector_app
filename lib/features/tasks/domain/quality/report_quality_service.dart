import 'package:inspector_app/features/tasks/domain/quality/before_after_compare.dart';
import 'package:inspector_app/features/tasks/domain/quality/report_templates.dart';
import 'package:inspector_app/features/tasks/domain/quality/voice_note_service.dart';

/// واجهة موحّدة لدوال جودة التفتيش.
class ReportQualityService {
  ReportQualityService._();

  static ReportTemplate templateForTask({String? title, String? description}) {
    return ReportTemplateCatalog.detectFromTask(title: title, description: description);
  }

  static ChecklistState createChecklist(ReportTemplate template) {
    return ChecklistState(template.checklist);
  }

  static String? validateBeforeSubmit({
    required ChecklistState checklist,
    required int attachmentCount,
    VoiceNoteMeta? voiceNote,
  }) {
    final checklistError = checklist.validate();
    if (checklistError != null) return checklistError;
    if (attachmentCount < 1) return 'يجب إرفاق صورة أو ملف واحد على الأقل';
    if (voiceNote != null) {
      final voiceError = VoiceNoteService.validationError(voiceNote);
      if (voiceError != null) return voiceError;
    }
    return null;
  }

  static List<BeforeAfterPair> compareVisits({
    required List<TaggedPhoto> previous,
    required List<TaggedPhoto> current,
  }) {
    return BeforeAfterCompare.buildPairs(
      previousVisit: previous,
      currentVisit: current,
    );
  }

  /// يدمج إجابات حقول القالب في نص ملاحظات التقرير.
  static String composeNotesFromTemplate({
    required ReportTemplate template,
    required Map<String, String> fieldValues,
    String? extraNotes,
    VoiceNoteMeta? voiceNote,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('قالب: ${template.title}');
    for (final field in template.fields) {
      final value = fieldValues[field.id]?.trim() ?? '';
      if (value.isEmpty) continue;
      buffer.writeln('- ${field.label}: $value');
    }
    if (extraNotes != null && extraNotes.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln(extraNotes.trim());
    }
    if (voiceNote != null) {
      buffer.writeln();
      buffer.writeln('[تعليق صوتي مرفق: ${voiceNote.filename}]');
    }
    return buffer.toString().trim();
  }
}
