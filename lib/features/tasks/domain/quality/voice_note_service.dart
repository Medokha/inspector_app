import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// تعليق صوتي قصير يُرفق مع التقرير.
class VoiceNoteMeta {
  const VoiceNoteMeta({
    required this.filePath,
    required this.filename,
    required this.sizeBytes,
    this.durationSeconds,
  });

  final String filePath;
  final String filename;
  final int sizeBytes;
  final int? durationSeconds;

  bool get isAcceptableSize => sizeBytes > 0 && sizeBytes <= 5 * 1024 * 1024; // 5MB
  bool get isAcceptableDuration =>
      durationSeconds == null || (durationSeconds! > 0 && durationSeconds! <= 90);
}

class VoiceNoteService {
  VoiceNoteService._();

  static const maxSeconds = 90;
  static const maxBytes = 5 * 1024 * 1024;

  /// يتحقق من ملف صوتي مختار (من المسجّل أو FilePicker).
  static Future<VoiceNoteMeta?> validateFile(String path, {int? durationSeconds}) async {
    final file = File(path);
    if (!await file.exists()) return null;
    final size = await file.length();
    final meta = VoiceNoteMeta(
      filePath: path,
      filename: p.basename(path),
      sizeBytes: size,
      durationSeconds: durationSeconds,
    );
    if (!meta.isAcceptableSize) return null;
    if (!meta.isAcceptableDuration) return null;
    return meta;
  }

  /// ينسخ المرفق الصوتي لمجلد التطبيق ليبقى متاحاً للمزامنة دون اتصال.
  static Future<String> persistForOffline(String sourcePath, {required String taskId}) async {
    final dir = await getApplicationDocumentsDirectory();
    final voiceDir = Directory(p.join(dir.path, 'voice_notes', taskId));
    if (!await voiceDir.exists()) {
      await voiceDir.create(recursive: true);
    }
    final name = 'voice_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
    final dest = p.join(voiceDir.path, name);
    await File(sourcePath).copy(dest);
    return dest;
  }

  static String? validationError(VoiceNoteMeta? meta) {
    if (meta == null) return 'ملف الصوت غير صالح';
    if (!meta.isAcceptableSize) return 'حجم التعليق الصوتي كبير جداً (الحد 5MB)';
    if (!meta.isAcceptableDuration) return 'مدة التعليق الصوتي يجب ألا تتجاوز $maxSeconds ثانية';
    return null;
  }
}
