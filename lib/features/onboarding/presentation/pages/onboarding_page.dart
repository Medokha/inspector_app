import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inspector_app/core/theme/app_theme.dart';
import 'package:inspector_app/features/auth/presentation/pages/login_page.dart';
import 'package:inspector_app/features/main/presentation/pages/main_shell_page.dart';
import 'package:inspector_app/core/di/injection.dart';

/// دليل استخدام تفاعلي لأول تشغيل.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const prefsKey = 'inspector_onboarding_done_v1';

  static Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey) ?? false;
  }

  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
  }

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = <_OnboardSlide>[
    _OnboardSlide(
      icon: Icons.assignment_turned_in_outlined,
      title: 'مهامك في مكان واحد',
      body: 'من الرئيسية ترى مهام اليوم، الإشعارات، والمهام الجارية.',
    ),
    _OnboardSlide(
      icon: Icons.my_location_outlined,
      title: 'ابدأ داخل نطاق الموقع',
      body: 'لن تُفتح المهمة إلا وأنت قريب من الموقع. أثناء التنفيذ يُسجَّل مسارك تلقائياً.',
    ),
    _OnboardSlide(
      icon: Icons.cloud_sync_outlined,
      title: 'يعمل دون اتصال',
      body: 'التقارير ونقاط المسار تُحفظ محلياً وتُزامَن عند عودة الشبكة.',
    ),
    _OnboardSlide(
      icon: Icons.description_outlined,
      title: 'تقرير احترافي',
      body: 'قوالب حسب نوع الوقف، قائمة تحقق، تعليق صوتي، ومقارنة قبل/بعد.',
    ),
    _OnboardSlide(
      icon: Icons.satellite_alt_outlined,
      title: 'تحليل قمري ذكي',
      body: 'شاهد الموقع من القمر الصناعي واحصل على تقييم مخاطر وتغيّر لمساعدة الزيارة والإدارة.',
    ),
  ];

  Future<void> _finish() async {
    await OnboardingPage.markDone();
    if (!mounted) return;
    final authed = currentAuthSession().isAuthenticated;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => authed ? const MainShellPage() : const LoginPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(onPressed: _finish, child: const Text('تخطي')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                          child: Icon(p.icon, size: 44, color: AppTheme.primaryNavy),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          p.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  width: i == _index ? 18 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _index ? AppTheme.accentGold : theme.dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: FilledButton(
                onPressed: () {
                  if (last) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(last ? 'ابدأ الآن' : 'التالي'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide {
  const _OnboardSlide({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}
