import 'package:flutter/material.dart';

import 'package:inspector_app/core/theme/app_theme.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('كيفية الاستخدام')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: <Color>[
                  AppTheme.primaryNavy,
                  AppTheme.primaryNavy.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'دليل المفتش',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'خطوات سريعة لإنجاز مهام التفتيش من التطبيق.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _GuideStep(
            number: '1',
            title: 'تسجيل الدخول',
            body: 'ادخل ببريدك وكلمة المرور المعتمدة. بعد الدخول تظهر لوحة الرئيسية بمهام اليوم والإشعارات.',
          ),
          const _GuideStep(
            number: '2',
            title: 'استلام المهمة',
            body: 'من «كل المهام» أو الرئيسية افتح المهمة. راجع الوصف والموقع على الخريطة وسبب الرفض إن وُجد.',
          ),
          const _GuideStep(
            number: '3',
            title: 'بدء التنفيذ',
            body: 'اضغط «بدء المهمة». يُفضّل تفعيل الموقع لتتبع المسار أثناء التنفيذ.',
          ),
          const _GuideStep(
            number: '4',
            title: 'رفع التقرير',
            body: 'أدخل الحالة العامة والجودة والملاحظات، ثم أرفق صورًا أو ملف PDF واحدًا على الأقل، ثم أرسل التقرير.',
          ),
          const _GuideStep(
            number: '5',
            title: 'المراجعة من الإدارة',
            body: 'بعد الرفع تنتظر اعتماد الإدارة. عند الرفض تظهر لك الملاحظات ويمكنك إعادة التنفيذ أو استلام مهمة موجّهة.',
          ),
          const _GuideStep(
            number: '6',
            title: 'مسار اليوم',
            body: 'تبويب «مساري اليوم» يعرض ترتيب الزيارات وخطًا يربط مواقع المهام على الخريطة حسب الموعد.',
          ),
          const _GuideStep(
            number: '7',
            title: 'الإشعارات والإعدادات',
            body: 'تابع الإشعارات أولًا بأول. من الإعدادات يمكنك تفعيل الوضع الليلي، ضبط تنبيهات المهام، وإعادة تعيين كلمة المرور.',
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.lightbulb_outline, color: theme.colorScheme.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'نصيحة: ارفع التقرير وأنت في الموقع قدر الإمكان، مع صور واضحة أو PDF رسمي، لتسريع الاعتماد.',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppTheme.accentGold,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
