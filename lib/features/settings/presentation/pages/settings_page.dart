import 'package:flutter/material.dart';
import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/features/auth/presentation/controller/session_controller.dart';
import 'package:inspector_app/features/auth/presentation/pages/login_page.dart';
import 'package:inspector_app/core/routing/page_transitions.dart';
import 'package:inspector_app/core/localization/app_localizations.dart';
import 'package:inspector_app/features/settings/presentation/controller/settings_controller.dart';
import 'package:inspector_app/features/settings/domain/entities/app_settings.dart';
import 'package:inspector_app/features/settings/presentation/pages/change_password_page.dart';
import 'package:inspector_app/features/settings/presentation/pages/support_page.dart';
import 'package:inspector_app/core/routing/page_transitions.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;
  late final SessionController _sessionController;

  @override
  void initState() {
    super.initState();
    _controller = createSettingsController();
    _sessionController = createSessionController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.logout),
        content: Text(strings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _sessionController.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        FadePageRoute(child: const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, _sessionController]),
      builder: (context, child) {
        final settings = _controller.settings;
        final user = _sessionController.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('الإعدادات'),
          ),
          body: settings == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                                user?.name.substring(0, 1) ?? 'أ',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user?.name ?? 'مستخدم',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // App Section
                    _SettingsSection(
                      title: 'التطبيق',
                      children: [
                        _SettingsSwitch(
                          label: 'الوضع الليلي (Dark Mode)',
                          icon: Icons.dark_mode_outlined,
                          value: settings.isDarkMode,
                          onChanged: (value) => _update(settings.copyWith(isDarkMode: value)),
                        ),
                        _SettingsSwitch(
                          label: 'تحميل الخرائط Offline',
                          icon: Icons.map_outlined,
                          value: settings.offlineMapsEnabled,
                          onChanged: (value) => _update(settings.copyWith(offlineMapsEnabled: value)),
                        ),
                        _InfoTile(
                          label: 'حجم ذاكرة التخزين',
                          icon: Icons.storage_outlined,
                          value: settings.storageUsedLabel,
                        ),
                        _InfoTile(
                          label: 'نسخة التطبيق',
                          icon: Icons.info_outline,
                          value: settings.appVersion,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Actions Section
                    _SettingsSection(
                      title: 'أخرى',
                      children: [
                        _ActionTile(
                          label: 'تغيير كلمة المرور',
                          icon: Icons.lock_outline,
                          onTap: () {
                            Navigator.push(context, FadePageRoute(child: const ChangePasswordPage()));
                          },
                        ),
                        _ActionTile(
                          label: 'الدعم الفني',
                          icon: Icons.support_agent_outlined,
                          onTap: () {
                            Navigator.push(context, FadePageRoute(child: const SupportPage()));
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
                        label: Text(AppLocalizations.of(context).logout, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    _controller.update(settings);
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
      activeColor: theme.colorScheme.primary,
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      secondary: Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7), size: 20),
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
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.w500,
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
