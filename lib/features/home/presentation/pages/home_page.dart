import 'package:flutter/material.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/features/home/presentation/controller/home_controller.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';
import 'package:inspector_app/features/tasks/presentation/pages/task_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onNavigateToTab,
    required this.onOpenNotifications,
  });

  final void Function(int) onNavigateToTab;
  final VoidCallback onOpenNotifications;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = createHomeController();
    _controller.load();
    _controller.startPolling();
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

        if (_controller.error != null && overview == null) {
          return Center(child: Text('تعذر تحميل البيانات'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _HeaderSection(
                name: overview?.inspectorName ?? 'المفتش',
                region: overview?.region ?? 'المنطقة',
                unreadCount: overview?.unreadNotifications ?? 0,
                onOpenNotifications: widget.onOpenNotifications,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCard(
                      label: 'مهام اليوم',
                      value: (overview?.totalToday ?? 0).toString(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'المُعادة',
                      value: (overview?.returnedCount ?? 0).toString(),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'المهام الجارية',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (final task in overview?.activeTasks ?? <TaskEntity>[]) ...<Widget>[
                _TaskCard(
                  task: task,
                  onTap: () => _openTaskDetails(task),
                ),
                const SizedBox(height: 12),
              ],
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => widget.onNavigateToTab(1),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('عرض كل المهام'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'الإشعارات الأخيرة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (final notification in overview?.recentNotifications ?? const [])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NotificationRow(
                    title: notification.title,
                    timeLabel: notification.timeLabel,
                    isUnread: notification.isUnread,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openTaskDetails(TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailsPage(taskId: task.id),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.name,
    required this.region,
    required this.unreadCount,
    required this.onOpenNotifications,
  });

  final String name;
  final String region;
  final int unreadCount;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                region,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: <Widget>[
            IconButton(
              onPressed: onOpenNotifications,
              icon: const Icon(Icons.notifications_outlined),
            ),
            if (unreadCount > 0)
              PositionedDirectional(
                top: 10,
                end: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD32F2F),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onTap});

  final TaskEntity task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _TaskStyle.fromStatus(task.status, theme);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: BorderDirectional(
            start: BorderSide(color: style.borderColor, width: 4),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _StatusChip(label: style.label, color: style.labelColor),
                const Spacer(),
                Text(
                  task.timeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              task.location,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (task.rejectionReason != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                task.rejectionReason!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.title,
    required this.timeLabel,
    required this.isUnread,
  });

  final String title;
  final String timeLabel;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsetsDirectional.only(top: 6, end: 8),
          decoration: BoxDecoration(
            color: isUnread ? theme.colorScheme.error : theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                timeLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskStyle {
  const _TaskStyle({required this.label, required this.labelColor, required this.borderColor});

  final String label;
  final Color labelColor;
  final Color borderColor;

  static _TaskStyle fromStatus(TaskStatus status, ThemeData theme) {
    switch (status) {
      case TaskStatus.inProgress:
        return _TaskStyle(label: 'جارية', labelColor: const Color(0xFFF57C00), borderColor: const Color(0xFFF57C00));
      case TaskStatus.returned:
        return _TaskStyle(label: 'مُعادة', labelColor: theme.colorScheme.error, borderColor: theme.colorScheme.error);
      case TaskStatus.pending:
        return _TaskStyle(label: 'معلقة', labelColor: const Color(0xFF1565C0), borderColor: const Color(0xFF90A4AE));
      case TaskStatus.completed:
        return _TaskStyle(label: 'منتهية', labelColor: const Color(0xFF2E7D32), borderColor: const Color(0xFF2E7D32));
      case TaskStatus.delayed:
        return _TaskStyle(label: 'متأخرة', labelColor: const Color(0xFFD32F2F), borderColor: const Color(0xFFD32F2F));
    }
  }
}
