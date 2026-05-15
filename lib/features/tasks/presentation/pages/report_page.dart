import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/features/tasks/presentation/controller/report_controller.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.taskId});

  final String taskId;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late final ReportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = createReportController(widget.taskId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('رفع التقرير'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              _SectionHeader(title: 'الحالة العامة للموقع'),
              const SizedBox(height: 12),
              _ReportOption(
                value: 'good',
                groupValue: _controller.generalCondition,
                label: 'جيد - العمل يسير حسب الخطة',
                onChanged: _controller.setCondition,
              ),
              _ReportOption(
                value: 'acceptable',
                groupValue: _controller.generalCondition,
                label: 'مقبول - تأخر بسيط أو ملاحظات',
                onChanged: _controller.setCondition,
              ),
              _ReportOption(
                value: 'weak',
                groupValue: _controller.generalCondition,
                label: 'ضعيف - مشاكل تحتاج تدخل',
                onChanged: _controller.setCondition,
              ),
              _ReportOption(
                value: 'stopped',
                groupValue: _controller.generalCondition,
                label: 'متوقف - العمل توقف كلياً',
                onChanged: _controller.setCondition,
              ),
              const SizedBox(height: 32),
              _SectionHeader(title: 'تقييم جودة التنفيذ'),
              const SizedBox(height: 16),
              Slider(
                value: _controller.qualityScore.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: '${_controller.qualityScore}%',
                onChanged: (value) => _controller.setScore(value.toInt()),
              ),
              Center(
                child: Text(
                  'نسبة الإنجاز الفعلية: ${_controller.qualityScore}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SwitchListTile.adaptive(
                value: _controller.hasViolations,
                onChanged: _controller.setViolations,
                title: const Text('هل توجد مخالفات في الموقع؟'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              _SectionHeader(title: 'الصور المرفقة'),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _controller.photoPaths.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == _controller.photoPaths.length) {
                      return _AddPhotoCard(onTap: _controller.pickImage);
                    }
                    return _PhotoPreviewCard(path: _controller.photoPaths[index]);
                  },
                ),
              ),
              const SizedBox(height: 32),
              _SectionHeader(title: 'ملاحظات المفتش'),
              const SizedBox(height: 12),
              TextField(
                maxLines: 4,
                onChanged: _controller.setNotes,
                decoration: const InputDecoration(
                  hintText: 'اكتب ملاحظاتك الفنية هنا...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _controller.isSubmitting
                      ? null
                      : () async {
                          await _controller.submit();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم حفظ التقرير بنجاح وسيتم رفعه تلقائياً')),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: _controller.isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.cloud_upload_outlined),
                  label: const Text('إرسال التقرير', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'سيتم حفظ التقرير محلياً في حال عدم توفر الإنترنت ورفعه لاحقاً',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
    );
  }
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _AddPhotoCard extends StatelessWidget {
  const _AddPhotoCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2), style: BorderStyle.solid),
        ),
        child: Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.primary),
      ),
    );
  }
}

class _PhotoPreviewCard extends StatelessWidget {
  const _PhotoPreviewCard({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: FileImage(File(path)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
