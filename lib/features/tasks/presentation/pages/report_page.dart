import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/security/photo_watermark_service.dart';
import 'package:inspector_app/core/ui/responsive.dart';
import 'package:inspector_app/core/ui/screen_insets.dart';
import 'package:inspector_app/features/tasks/domain/quality/before_after_compare.dart';
import 'package:inspector_app/features/tasks/domain/quality/previous_visit_photo.dart';
import 'package:inspector_app/features/tasks/domain/quality/report_quality_service.dart';
import 'package:inspector_app/features/tasks/domain/quality/report_templates.dart';
import 'package:inspector_app/features/tasks/domain/quality/voice_note_service.dart';
import 'package:inspector_app/features/tasks/presentation/controller/report_controller.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({
    super.key,
    required this.taskId,
    this.taskTitle,
    this.taskDescription,
    this.previousPhotos = const <PreviousVisitPhoto>[],
  });

  final String taskId;
  final String? taskTitle;
  final String? taskDescription;
  final List<PreviousVisitPhoto> previousPhotos;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late final ReportController _controller;
  final _notesController = TextEditingController();
  final _picker = ImagePicker();
  final Map<String, TextEditingController> _fieldControllers = {};

  late ReportTemplate _template;
  late ChecklistState _checklist;
  WaqfSiteType _siteType = WaqfSiteType.general;

  String _selected = 'جيد - العمل يسير حسب الخطة';
  int _qualityScore = 4;
  bool _hasIssues = false;
  final List<_ReportAttachment> _attachments = <_ReportAttachment>[];
  VoiceNoteMeta? _voiceNote;
  final Map<String, PhotoAngleTag> _attachmentAngles = <String, PhotoAngleTag>{};

  List<BeforeAfterPair> get _beforeAfterPairs {
    if (widget.previousPhotos.isEmpty || _attachments.isEmpty) {
      return const <BeforeAfterPair>[];
    }
    final previous = widget.previousPhotos.map((p) => p.toTagged()).toList();
    final current = <TaggedPhoto>[];
    for (var i = 0; i < _attachments.length; i++) {
      final a = _attachments[i];
      if (a.isPdf) continue;
      final key = '${a.filename}_$i';
      current.add(
        TaggedPhoto(
          id: key,
          urlOrPath: a.filename,
          angle: _attachmentAngles[key] ?? BeforeAfterCompare.guessAngle(a.filename),
          capturedAt: DateTime.now(),
        ),
      );
    }
    return ReportQualityService.compareVisits(previous: previous, current: current);
  }

  @override
  void initState() {
    super.initState();
    _controller = createReportController();
    _template = ReportQualityService.templateForTask(
      title: widget.taskTitle,
      description: widget.taskDescription,
    );
    _siteType = _template.siteType;
    _checklist = ReportQualityService.createChecklist(_template);
    _rebuildFieldControllers();
  }

  void _rebuildFieldControllers() {
    for (final c in _fieldControllers.values) {
      c.dispose();
    }
    _fieldControllers
      ..clear()
      ..addEntries(
        _template.fields.map(
          (f) => MapEntry(f.id, TextEditingController()),
        ),
      );
  }

  void _applySiteType(WaqfSiteType type) {
    setState(() {
      _siteType = type;
      _template = ReportTemplateCatalog.forType(type);
      _checklist = ReportQualityService.createChecklist(_template);
      _rebuildFieldControllers();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    for (final c in _fieldControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _isPdfName(String name) => name.toLowerCase().endsWith('.pdf');

  Future<void> _pickPhoto({required ImageSource source}) async {
    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;
    var bytes = await file.readAsBytes();
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      bytes = PhotoWatermarkService.apply(
        bytes: Uint8List.fromList(bytes),
        capturedAt: DateTime.now(),
        latitude: pos.latitude,
        longitude: pos.longitude,
        taskId: widget.taskId,
      );
    } catch (_) {
      bytes = PhotoWatermarkService.apply(
        bytes: Uint8List.fromList(bytes),
        capturedAt: DateTime.now(),
        taskId: widget.taskId,
      );
    }
    setState(() {
      _attachments.add(
        _ReportAttachment(
          bytes: bytes,
          filename: file.name.isEmpty ? 'photo.jpg' : file.name,
          isPdf: false,
        ),
      );
      final key = '${file.name.isEmpty ? 'photo.jpg' : file.name}_${_attachments.length - 1}';
      _attachmentAngles[key] = BeforeAfterCompare.guessAngle(file.name);
    });
  }

  Future<void> _pickFiles() async {
    final files = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const <String>['jpg', 'jpeg', 'png', 'webp', 'gif', 'pdf'],
    );
    if (files.isEmpty) return;

    final added = <_ReportAttachment>[];
    for (final file in files) {
      final name = file.name;
      late final List<int> bytes;
      try {
        bytes = await file.readAsBytes();
      } catch (_) {
        continue;
      }
      if (bytes.isEmpty) continue;
      added.add(
        _ReportAttachment(
          bytes: bytes,
          filename: name.isEmpty ? 'attachment.bin' : name,
          isPdf: _isPdfName(name),
        ),
      );
    }
    if (added.isEmpty) return;
    setState(() => _attachments.addAll(added));
  }

  Future<void> _pickVoice() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['m4a', 'aac', 'mp3', 'wav', 'ogg'],
    );
    if (files.isEmpty) return;
    final file = files.first;
    final path = file.path;
    if (path == null || path.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر قراءة ملف الصوت على هذا الجهاز'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final meta = await VoiceNoteService.validateFile(path);
    final error = VoiceNoteService.validationError(meta);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _voiceNote = meta);
  }

  Future<void> _chooseSource() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('الكاميرا'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(source: ImageSource.camera);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('صورة من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(source: ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('ملف PDF أو صور'),
              subtitle: const Text('يمكن اختيار أكثر من ملف'),
              onTap: () {
                Navigator.pop(context);
                _pickFiles();
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic_none_outlined),
              title: const Text('تعليق صوتي'),
              subtitle: const Text('ملف قصير بحد أقصى 90 ثانية'),
              onTap: () {
                Navigator.pop(context);
                _pickVoice();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final photoFiles = _attachments
        .map((a) => (bytes: a.bytes, filename: a.filename))
        .toList();

    final fieldValues = <String, String>{
      for (final e in _fieldControllers.entries) e.key: e.value.text.trim(),
    };

    final ok = await _controller.submit(
      taskId: widget.taskId,
      generalCondition: _selected,
      qualityScore: _qualityScore,
      hasViolations: _hasIssues,
      reportNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      photoFiles: photoFiles,
      checklist: _checklist,
      template: _template,
      templateFields: fieldValues,
      voiceNote: _voiceNote,
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ/رفع التقرير (يُزامَن تلقائياً عند توفر الشبكة)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.error ?? 'تعذر رفع التقرير'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_template.title),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ListView(
            padding: ScreenInsets.list(
              context,
              horizontal: Responsive.pagePadding(context),
              top: 16,
              extraBottom: 32,
            ),
            children: <Widget>[
              if (widget.taskTitle != null) ...<Widget>[
                Text(widget.taskTitle!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
              ],
              Text('نوع الوقف', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: WaqfSiteType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.labelAr),
                    selected: _siteType == type,
                    onSelected: (_) => _applySiteType(type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('قائمة التحقق (إلزامية)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._checklist.definitions.map((item) {
                return CheckboxListTile(
                  value: _checklist.checked[item.id] ?? false,
                  onChanged: (v) => setState(() => _checklist.setChecked(item.id, v ?? false)),
                  title: Text(item.label),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }),
              const SizedBox(height: 16),
              Text('حقول القالب', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._template.fields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _fieldControllers[field.id],
                    decoration: InputDecoration(
                      labelText: field.label + (field.required ? ' *' : ''),
                      hintText: field.hint,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text('الحالة العامة للموقع', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _ReportOption(
                value: 'جيد - العمل يسير حسب الخطة',
                groupValue: _selected,
                label: 'جيد - العمل يسير حسب الخطة',
                onChanged: (value) => setState(() => _selected = value),
              ),
              _ReportOption(
                value: 'مقبول - تأخر بسيط أو ملاحظات',
                groupValue: _selected,
                label: 'مقبول - تأخر بسيط أو ملاحظات',
                onChanged: (value) => setState(() => _selected = value),
              ),
              _ReportOption(
                value: 'ضعيف - مشاكل تحتاج تدخل',
                groupValue: _selected,
                label: 'ضعيف - مشاكل تحتاج تدخل',
                onChanged: (value) => setState(() => _selected = value),
              ),
              _ReportOption(
                value: 'متوقف - العمل توقف كلياً',
                groupValue: _selected,
                label: 'متوقف - العمل توقف كلياً',
                onChanged: (value) => setState(() => _selected = value),
              ),
              const SizedBox(height: 16),
              Text('تقييم جودة التنفيذ', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              Slider(
                value: _qualityScore.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '$_qualityScore / 5',
                onChanged: (value) => setState(() => _qualityScore = value.round()),
              ),
              Text('درجة الجودة $_qualityScore من 5'),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                value: _hasIssues,
                onChanged: (value) => setState(() => _hasIssues = value),
                title: const Text('مخالفات موجودة؟'),
              ),
              const SizedBox(height: 16),
              Text('المرفقات — إلزامي', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  ...List<Widget>.generate(_attachments.length, (index) {
                    final file = _attachments[index];
                    final key = '${file.filename}_$index';
                    return InputChip(
                      avatar: Icon(
                        file.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
                        size: 18,
                      ),
                      label: Text(
                        file.isPdf
                            ? file.filename
                            : '${file.filename} (${(_attachmentAngles[key] ?? PhotoAngleTag.other).labelAr})',
                        overflow: TextOverflow.ellipsis,
                      ),
                      onDeleted: () => setState(() {
                        _attachments.removeAt(index);
                        _attachmentAngles.remove(key);
                      }),
                      onPressed: file.isPdf
                          ? null
                          : () async {
                              final selected = await showModalBottomSheet<PhotoAngleTag>(
                                context: context,
                                showDragHandle: true,
                                builder: (ctx) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: PhotoAngleTag.values
                                        .map(
                                          (tag) => ListTile(
                                            title: Text(tag.labelAr),
                                            onTap: () => Navigator.pop(ctx, tag),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              );
                              if (selected != null) {
                                setState(() => _attachmentAngles[key] = selected);
                              }
                            },
                    );
                  }),
                  if (_voiceNote != null)
                    Chip(
                      avatar: const Icon(Icons.mic, size: 18),
                      label: Text(_voiceNote!.filename, overflow: TextOverflow.ellipsis),
                      onDeleted: () => setState(() => _voiceNote = null),
                    ),
                  ActionChip(
                    avatar: Icon(Icons.attach_file, color: theme.colorScheme.primary),
                    label: const Text('إضافة مرفق / صوت'),
                    onPressed: _chooseSource,
                  ),
                ],
              ),
              if (widget.previousPhotos.isNotEmpty) ...<Widget>[
                const SizedBox(height: 20),
                Text(
                  'مقارنة قبل / بعد',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'اختر زاوية كل صورة بالضغط عليها لربطها بصور الزيارة السابقة',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  BeforeAfterCompare.summary(_beforeAfterPairs),
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ..._beforeAfterPairs.map((pair) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        pair.isComplete ? Icons.compare_rounded : Icons.compare_arrows_outlined,
                        color: pair.isComplete ? theme.colorScheme.primary : theme.colorScheme.outline,
                      ),
                      title: Text(pair.angle.labelAr),
                      subtitle: Text(
                        pair.isComplete
                            ? 'مكتمل: قبل وبعد لنفس الزاوية'
                            : pair.before == null
                                ? 'أضف صورة لهذه الزاوية'
                                : 'بانتظار صورة حالية',
                      ),
                      trailing: pair.isComplete
                          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                          : null,
                    ),
                  );
                }),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'ملاحظات إضافية...',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _controller.isSubmitting ? null : _submit,
                icon: _controller.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_controller.isSubmitting ? 'جارٍ الإرسال...' : 'إرسال التقرير'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportAttachment {
  const _ReportAttachment({
    required this.bytes,
    required this.filename,
    required this.isPdf,
  });

  final List<int> bytes;
  final String filename;
  final bool isPdf;
}

class _ReportOption extends StatelessWidget {
  const _ReportOption({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  final String value;
  final String groupValue;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: (value) => onChanged(value ?? groupValue),
      title: Text(label),
      contentPadding: EdgeInsets.zero,
    );
  }
}
