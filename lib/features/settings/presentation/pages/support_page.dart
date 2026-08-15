import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:inspector_app/core/theme/app_theme.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const _supportEmail = 'support@swa.gov.iq';
  static const _supportPhone = '07800000000';

  Future<void> _mail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: <String, String>{
        'subject': 'دعم تطبيق المفتش',
        'body': 'السلام عليكم،\n\nأحتاج مساعدة بخصوص:\n',
      },
    );
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح تطبيق البريد. راسلنا على $_supportEmail'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _call(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: _supportPhone);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح الاتصال'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('الدعم الفني')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withValues(alpha: theme.brightness == Brightness.dark ? 0.35 : 0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.support_agent_rounded, color: theme.colorScheme.secondary, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'نحن هنا لمساعدتك',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'للاستفسارات التقنية أو مشاكل تسجيل الدخول أو رفع التقارير، تواصل مع فريق الدعم.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('البريد الإلكتروني', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text(_supportEmail),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => _mail(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('الهاتف', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text(_supportPhone),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => _call(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'قبل التواصل',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  _Tip(text: 'تأكد من اتصالك بالإنترنت.'),
                  _Tip(text: 'حدّث التطبيق لأحدث نسخة إن أمكن.'),
                  _Tip(text: 'جرّب تسجيل الخروج ثم الدخول من جديد.'),
                  _Tip(text: 'عند رفع تقرير: أرفق صورة أو PDF واحد على الأقل.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _mail(context),
            icon: const Icon(Icons.send_outlined),
            label: const Text('إرسال رسالة دعم'),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.check_circle_outline, size: 18, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
