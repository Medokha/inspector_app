import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// ختم زمني وموقع على كل صورة لتقليل التلاعب.
class PhotoWatermarkService {
  PhotoWatermarkService._();

  /// يضيف شريطاً أسفل الصورة يحتوي التاريخ/الوقت والإحداثيات ومعرّف المهمة.
  static Uint8List apply({
    required Uint8List bytes,
    required DateTime capturedAt,
    double? latitude,
    double? longitude,
    String? taskId,
    String? inspectorLabel,
  }) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    final image = img.copyResize(
      decoded,
      width: decoded.width > 1600 ? 1600 : decoded.width,
    );

    final stamp = StringBuffer()
      ..write(capturedAt.toLocal().toIso8601String().replaceFirst('T', ' ').split('.').first)
      ..write(' | ');
    if (latitude != null && longitude != null) {
      stamp.write('${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}');
    } else {
      stamp.write('بدون إحداثيات');
    }
    if (taskId != null && taskId.isNotEmpty) {
      stamp.write(' | مهمة ${taskId.length > 8 ? taskId.substring(0, 8) : taskId}');
    }
    if (inspectorLabel != null && inspectorLabel.isNotEmpty) {
      stamp.write(' | $inspectorLabel');
    }

    final barHeight = (image.height * 0.06).clamp(28, 56).toInt();
    img.fillRect(
      image,
      x1: 0,
      y1: image.height - barHeight,
      x2: image.width,
      y2: image.height,
      color: img.ColorRgba8(32, 45, 69, 200),
    );

    img.drawString(
      image,
      stamp.toString(),
      font: img.arial24,
      x: 12,
      y: image.height - barHeight + (barHeight ~/ 4),
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    return Uint8List.fromList(img.encodeJpg(image, quality: 85));
  }
}
