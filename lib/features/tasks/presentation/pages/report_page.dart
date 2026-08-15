import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/ui/screen_insets.dart';
import 'package:inspector_app/features/tasks/presentation/controller/report_controller.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.taskId, this.taskTitle});

  final String taskId;
  final String? taskTitle;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late final ReportController _controller;
  final _notesController = TextEditingController();
  final _picker = ImagePicker();

  String _selected = 'جيد - العمل يسير حسب الخطة';
  int _qualityScore = 4;
  bool _hasIssues = false;
  final List<_ReportAttachment> _attachments = <_ReportAttachment>[];

  @override
  void initState() {
    super.initState();
    _controller = createReportController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _isPdfName(String name) => name.toLowerCase().endsWith('.pdf');

  Future<void> _pickPhoto({required ImageSource source}) async {
    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _attachments.add(
        _ReportAttachment(
          bytes: bytes,
          filename: file.name.isEmpty ? 'photo.jpg' : file.name,
          isPdf: false,
        ),
      );
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
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إرفاق صورة أو ملف PDF واحد على الأقل'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final photoFiles = _attachments
        .map((a) => (bytes: a.bytes, filename: a.filename))
        .toList();

    final ok = await _controller.submit(
      taskId: widget.taskId,
      generalCondition: _selected,
      qualityScore: _qualityScore,
      hasViolations: _hasIssues,
      reportNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      photoFiles: photoFiles,
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع التقرير بنجاح'), behavior: SnackBarBehavior.floating),
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
        title: const Text('رفع التقرير'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ListView(
            padding: ScreenInsets.list(context, horizontal: 16, top: 16, extraBottom: 32),
            children: <Widget>[
              if (widget.taskTitle != null) ...<Widget>[
                Text(widget.taskTitle!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
              ],
              Text(
                'الحالة العامة للموقع',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
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
              Text(
                'تقييم جودة التنفيذ',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
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
              Text(
                'المرفقات (صورة أو PDF) — إلزامي',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'يمكنك رفع صور وملفات PDF معاً',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  ..._attachments.map(
                    (file) => Chip(
                      avatar: Icon(
                        file.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
                        size: 18,
                      ),
                      label: Text(file.filename, overflow: TextOverflow.ellipsis),
                      onDeleted: () => setState(() => _attachments.remove(file)),
                    ),
                  ),
                  ActionChip(
                    avatar: Icon(Icons.attach_file, color: theme.colorScheme.primary),
                    label: const Text('إضافة مرفق'),
                    onPressed: _chooseSource,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'اكتب ملاحظات هنا...',
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
