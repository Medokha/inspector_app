import 'package:flutter/material.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/features/profile/domain/entities/profile_overview.dart';
import 'package:inspector_app/features/profile/domain/entities/report_item.dart';
import 'package:inspector_app/features/profile/presentation/controller/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = createProfileController();
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
        final overview = _controller.overview;
        if (_controller.isLoading && overview == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (overview == null) {
          return const Center(child: Text('لا توجد بيانات متاحة'));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('ملفي الشخصي'),
            actions: <Widget>[
              IconButton(
                onPressed: widget.onOpenSettings,
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: _buildBody(context, overview),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProfileOverview overview) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 38,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  overview.profile.initials,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                overview.profile.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                overview.profile.region,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: overview.profile.tags
                    .map((tag) => _TagChip(label: tag))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('إحصائيات الأداء - مايو ٢٠٢٦', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(child: _StatMiniCard(label: 'مكتملة', value: overview.stats.completed.toString())),
            const SizedBox(width: 8),
            Expanded(child: _StatMiniCard(label: 'معلقة', value: overview.stats.pending.toString())),
            const SizedBox(width: 8),
            Expanded(child: _StatMiniCard(label: 'مرفوضة', value: overview.stats.rejected.toString())),
            const SizedBox(width: 8),
            Expanded(child: _StatMiniCard(label: 'متأخرة', value: overview.stats.late.toString())),
          ],
        ),
        const SizedBox(height: 16),
        for (final metric in overview.metrics) ...<Widget>[
          _MetricRow(label: metric.label, value: metric.value),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 12),
        Text('آخر تقارير', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final report in overview.recentReports) ...<Widget>[
          _ReportTile(item: report),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
            Text('$value%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ],
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.item});

  final ReportItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _ReportStyle.fromStatus(item.status, theme);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(item.title, style: theme.textTheme.bodyMedium),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: status.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(item.dateLabel, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ReportStyle {
  const _ReportStyle({required this.label, required this.color});

  final String label;
  final Color color;

  static _ReportStyle fromStatus(ReportStatus status, ThemeData theme) {
    switch (status) {
      case ReportStatus.accepted:
        return const _ReportStyle(label: 'معتمد', color: Color(0xFF2E7D32));
      case ReportStatus.rejected:
        return _ReportStyle(label: 'مرفوض', color: theme.colorScheme.error);
      case ReportStatus.pending:
        return const _ReportStyle(label: 'قيد المراجعة', color: Color(0xFFF57C00));
    }
  }
}
