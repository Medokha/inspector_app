import 'package:flutter/material.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/localization/app_localizations.dart';
import 'package:inspector_app/core/routing/page_transitions.dart';
import 'package:inspector_app/core/security/biometric_auth_service.dart';
import 'package:inspector_app/core/notifications/notification_prefs.dart';
import 'package:inspector_app/core/ui/responsive.dart';
import 'package:inspector_app/core/ui/screen_insets.dart';
import 'package:inspector_app/features/auth/presentation/pages/login_page.dart';
import 'package:inspector_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:inspector_app/features/settings/domain/entities/app_settings.dart';
import 'package:inspector_app/features/settings/presentation/controller/settings_controller.dart';
import 'package:inspector_app/features/settings/presentation/pages/how_to_use_page.dart';
import 'package:inspector_app/features/settings/presentation/pages/support_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;
  bool _biometricEnabled = false;
  bool _biometricSupported = false;
  bool _satelliteAlerts = true;

  @override
  void initState() {
    super.initState();
    _controller = createSettingsController();
    _controller.load();
    _loadBiometric();
    _loadSatelliteAlerts();
  }

  Future<void> _loadSatelliteAlerts() async {
    final v = await NotificationPrefs.satelliteRiskAlerts;
    if (!mounted) return;
    setState(() => _satelliteAlerts = v);
  }

  Future<void> _loadBiometric() async {
    final supported = await BiometricAuthService.isDeviceSupported;
    final enabled = await BiometricAuthService.isEnabled;
    if (!mounted) return;
    setState(() {
      _biometricSupported = supported;
      _biometricEnabled = enabled;
    });
  }

  @override
  void dispose() {
    // لا تُغلق الـ SettingsController المشترك — يستخدمه MaterialApp لتبديل الثيم.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final settings = _controller.settings;
        final session = currentAuthSession();
        final displayName = (session.name == null || session.name!.isEmpty) ? 'مفتش' : session.name!;
        final displayEmail = session.email ?? '';
        final initials = session.initials;
        return Scaffold(
          appBar: AppBar(
            title: const Text('الإعدادات'),
          ),
          body: settings == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: ScreenInsets.list(
                    context,
                    horizontal: Responsive.pagePadding(context),
                    top: 16,
                    extraBottom: 40,
                  ),
                  children: <Widget>[
                    // User Header Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              child: Text(
                                initials,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              displayName,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayEmail.isEmpty ? '—' : displayEmail,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Notifications Section
                    _SettingsSection(
                      title: 'الإشعارات',
                      children: [
                        _SettingsSwitch(
                          label: 'مهام جديدة',
                          icon: Icons.assignment_outlined,
                          value: settings.newTasks,
                          onChanged: (value) => _update(settings.copyWith(newTasks: value)),
                        ),
                        _SettingsSwitch(
                          label: 'اعتماد/رفض التقارير',
                          icon: Icons.description_outlined,
                          value: settings.reportApprovals,
                          onChanged: (value) => _update(settings.copyWith(reportApprovals: value)),
                        ),
                        _SettingsSwitch(
                          label: 'تذكير موعد المهمة',
                          icon: Icons.notifications_active_outlined,
                          value: settings.deadlineReminders,
                          onChanged: (value) => _update(settings.copyWith(deadlineReminders: value)),
                        ),
                        _SettingsSwitch(
                          label: 'تنبيهات المخاطر القمرية',
                          icon: Icons.satellite_alt_outlined,
                          value: _satelliteAlerts,
                          onChanged: (value) async {
                            await NotificationPrefs.setSatelliteRiskAlerts(value);
                            if (!mounted) return;
                            setState(() => _satelliteAlerts = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // App Section
                    _SettingsSection(
                      title: 'التطبيق',
                      children: [
                        _SettingsSwitch(
                          label: 'الوضع الليلي',
                          icon: Icons.dark_mode_outlined,
                          value: settings.isDarkMode,
                          onChanged: (value) => _update(settings.copyWith(isDarkMode: value)),
                        ),
                        _SettingsSwitch(
                          label: 'وضع ليلي ميداني (تباين عالي)',
                          icon: Icons.wb_sunny_outlined,
                          value: settings.fieldNightMode,
                          onChanged: (value) => _update(
                            settings.copyWith(
                              fieldNightMode: value,
                              isDarkMode: value ? true : settings.isDarkMode,
                            ),
                          ),
                        ),
                        _SettingsSwitch(
                          label: 'تحميل الخرائط دون اتصال',
                          icon: Icons.map_outlined,
                          value: settings.offlineMapsEnabled,
                          onChanged: (value) => _update(settings.copyWith(offlineMapsEnabled: value)),
                        ),
                        if (_biometricSupported)
                          _SettingsSwitch(
                            label: 'فتح التطبيق بالبصمة / الوجه',
                            icon: Icons.fingerprint,
                            value: _biometricEnabled,
                            onChanged: (value) async {
                              if (value) {
                                final email = currentAuthSession().email;
                                if (email == null || email.isEmpty) return;
                                await BiometricAuthService.enableAfterPasswordLogin(email);
                              } else {
                                await BiometricAuthService.disable();
                              }
                              if (!mounted) return;
                              setState(() => _biometricEnabled = value);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // مزامنة الميدان
                    _SettingsSection(
                      title: 'المزامنة الميدانية',
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: fieldSyncService().pendingCount,
                          builder: (context, pending, _) {
                            return _ActionTile(
                              label: pending > 0
                                  ? 'مزامنة الآن ($pending معلّق)'
                                  : 'مزامنة الآن — لا يوجد معلّق',
                              icon: Icons.sync_rounded,
                              onTap: () async {
                                final n = await fieldSyncService().syncPending();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      n > 0 ? 'تمت مزامنة $n عنصر' : 'لا توجد عناصر للمزامنة أو الشبكة غير متاحة',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Actions Section
                    _SettingsSection(
                      title: 'أخرى',
                      children: [
                        _ActionTile(
                          label: 'كيفية الاستخدام',
                          icon: Icons.menu_book_outlined,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const HowToUsePage()),
                            );
                          },
                        ),
                        _ActionTile(
                          label: 'الدعم الفني',
                          icon: Icons.support_agent_outlined,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SupportPage()),
                            );
                          },
                        ),
                        _ActionTile(
                          label: AppLocalizations.of(context).resetPasswordTitle,
                          icon: Icons.lock_reset_outlined,
                          onTap: () {
                            Navigator.of(context).push(
                              SlideUpPageRoute(child: const ResetPasswordPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
                          foregroundColor: theme.colorScheme.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
        );
      },
    );
  }

  void _update(AppSettings settings) {
    _controller.update(settings).catchError((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر حفظ الإعدادات'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  Future<void> _logout() async {
    await logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      FadePageRoute(child: const LoginPage()),
      (route) => false,
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8, bottom: 12),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      secondary: Icon(icon, color: theme.colorScheme.primary.withValues(alpha: 0.75), size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.icon, required this.value});

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7), size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.35),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7), size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      trailing: Icon(Icons.chevron_left_rounded, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.3)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: onTap,
    );
  }
}
