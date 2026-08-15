import 'package:inspector_app/features/tasks/domain/quality/before_after_compare.dart';

/// صورة سابقة من زيارة مرفوضة/سابقة لعرض المقارنة قبل/بعد.
class PreviousVisitPhoto {
  const PreviousVisitPhoto({
    required this.id,
    required this.url,
    this.fileName,
    this.description,
  });

  final String id;
  final String url;
  final String? fileName;
  final String? description;

  TaggedPhoto toTagged() {
    return TaggedPhoto(
      id: id,
      urlOrPath: url,
      angle: BeforeAfterCompare.guessAngle('${fileName ?? ''} ${description ?? ''}'),
      capturedAt: DateTime.fromMillisecondsSinceEpoch(0),
      isBefore: true,
    );
  }
}
