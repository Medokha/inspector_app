/// صورة موسمية لنفس الزاوية (قبل / بعد).
enum PhotoAngleTag {
  facade,
  hall,
  yard,
  utilities,
  other,
}

extension PhotoAngleTagX on PhotoAngleTag {
  String get labelAr {
    switch (this) {
      case PhotoAngleTag.facade:
        return 'واجهة';
      case PhotoAngleTag.hall:
        return 'قاعة / داخل';
      case PhotoAngleTag.yard:
        return 'ساحة';
      case PhotoAngleTag.utilities:
        return 'خدمات';
      case PhotoAngleTag.other:
        return 'أخرى';
    }
  }
}

class TaggedPhoto {
  const TaggedPhoto({
    required this.id,
    required this.urlOrPath,
    required this.angle,
    required this.capturedAt,
    this.isBefore = false,
  });

  final String id;
  final String urlOrPath;
  final PhotoAngleTag angle;
  final DateTime capturedAt;
  final bool isBefore;
}

class BeforeAfterPair {
  const BeforeAfterPair({
    required this.angle,
    this.before,
    this.after,
  });

  final PhotoAngleTag angle;
  final TaggedPhoto? before;
  final TaggedPhoto? after;

  bool get isComplete => before != null && after != null;
}

/// مقارنة قبل/بعد لصور نفس الزاوية بين الزيارات.
class BeforeAfterCompare {
  BeforeAfterCompare._();

  /// يبني أزواج المقارنة من صور الزيارة السابقة والحالية.
  static List<BeforeAfterPair> buildPairs({
    required List<TaggedPhoto> previousVisit,
    required List<TaggedPhoto> currentVisit,
  }) {
    final angles = <PhotoAngleTag>{
      ...previousVisit.map((e) => e.angle),
      ...currentVisit.map((e) => e.angle),
    };

    TaggedPhoto? latestFor(List<TaggedPhoto> list, PhotoAngleTag angle) {
      final matches = list.where((p) => p.angle == angle).toList()
        ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      return matches.isEmpty ? null : matches.first;
    }

    return angles.map((angle) {
      return BeforeAfterPair(
        angle: angle,
        before: latestFor(previousVisit, angle),
        after: latestFor(currentVisit, angle),
      );
    }).toList()
      ..sort((a, b) => a.angle.index.compareTo(b.angle.index));
  }

  /// يقترح زاوية من اسم الملف أو الوصف.
  static PhotoAngleTag guessAngle(String? nameOrDescription) {
    final t = (nameOrDescription ?? '').toLowerCase();
    if (t.contains('واجهة') || t.contains('facade') || t.contains('front')) {
      return PhotoAngleTag.facade;
    }
    if (t.contains('قاعة') || t.contains('داخل') || t.contains('hall') || t.contains('inside')) {
      return PhotoAngleTag.hall;
    }
    if (t.contains('ساحة') || t.contains('yard') || t.contains('court')) {
      return PhotoAngleTag.yard;
    }
    if (t.contains('كهرب') || t.contains('ماء') || t.contains('util')) {
      return PhotoAngleTag.utilities;
    }
    return PhotoAngleTag.other;
  }

  static String summary(List<BeforeAfterPair> pairs) {
    final complete = pairs.where((p) => p.isComplete).length;
    return 'مقارنات مكتملة: $complete من ${pairs.length}';
  }
}
