import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _selected = 'good';
  bool _hasIssues = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع التقرير'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'الحالة العامة للموقع',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ReportOption(
            value: 'good',
            groupValue: _selected,
            label: 'جيد - العمل يسير حسب الخطة',
            onChanged: (value) => setState(() => _selected = value),
          ),
          _ReportOption(
            value: 'acceptable',
            groupValue: _selected,
            label: 'مقبول - تأخر بسيط أو ملاحظات',
            onChanged: (value) => setState(() => _selected = value),
          ),
          _ReportOption(
            value: 'weak',
            groupValue: _selected,
            label: 'ضعيف - مشاكل تحتاج تدخل',
            onChanged: (value) => setState(() => _selected = value),
          ),
          _ReportOption(
            value: 'stopped',
            groupValue: _selected,
            label: 'متوقف - العمل توقف كلياً',
            onChanged: (value) => setState(() => _selected = value),
          ),
          const SizedBox(height: 16),
          Text(
            'تقييم جودة التنفيذ',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const LinearProgressIndicator(value: 0.75),
          const SizedBox(height: 8),
          const Text('نسبة الإنجاز الفعلية 75%'),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            value: _hasIssues,
            onChanged: (value) => setState(() => _hasIssues = value),
            title: const Text('مخالفات موجودة؟'),
          ),
          const SizedBox(height: 16),
          Text(
            'الصور المرفقة - إلزامي',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _UploadPlaceholder(color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              _UploadPlaceholder(color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              _UploadPlaceholder(color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'اكتب ملاحظات هنا...',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.send_outlined),
            label: const Text('إرسال التقرير'),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم حفظ التقرير محلياً لحين توفر الإنترنت',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(
          child: Icon(Icons.add, color: color),
        ),
      ),
    );
  }
}
