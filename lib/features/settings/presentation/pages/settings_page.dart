import 'package:flutter/material.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/features/settings/domain/entities/app_settings.dart';
import 'package:inspector_app/features/settings/presentation/controller/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = createSettingsController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final settings = _controller.settings;
        return Scaffold(
          appBar: AppBar(
            title: const Text('الإعدادات'),
          ),
          body: settings == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              'أخ',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('أحمد النجفي'),
                          Text(
                            'inspector@waqf.iq',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('الإشعارات', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    _SettingsSwitch(
                      label: 'مهام جديدة',
                      value: settings.newTasks,
                      onChanged: (value) => _update(settings.copyWith(newTasks: value)),
                    ),
                    _SettingsSwitch(
                      label: 'اعتماد/رفض التقارير',
                      value: settings.reportApprovals,
                      onChanged: (value) => _update(settings.copyWith(reportApprovals: value)),
                    ),
                    _SettingsSwitch(
                      label: 'تذكير موعد المهمة',
                      value: settings.deadlineReminders,
                      onChanged: (value) => _update(settings.copyWith(deadlineReminders: value)),
                    ),
                    const SizedBox(height: 16),
                    Text('التطبيق', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    _SettingsSwitch(
                      label: 'تحميل الخرائط Offline',
                      value: settings.offlineMapsEnabled,
                      onChanged: (value) => _update(settings.copyWith(offlineMapsEnabled: value)),
                    ),
                    const SizedBox(height: 8),
                    _InfoTile(label: 'حجم ذاكرة التخزين', value: settings.storageUsedLabel),
                    _InfoTile(label: 'نسخة التطبيق', value: settings.appVersion),
                    const SizedBox(height: 16),
                    _ActionTile(label: 'تغيير كلمة المرور'),
                    _ActionTile(label: 'الدعم الفني'),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout),
                      label: const Text('تسجيل الخروج'),
                    ),
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

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Text(label),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(value),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
      onTap: () {},
    );
  }
}
