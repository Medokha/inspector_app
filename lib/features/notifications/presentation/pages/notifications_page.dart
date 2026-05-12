import 'package:flutter/material.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/features/notifications/domain/entities/notification_item.dart';
import 'package:inspector_app/features/notifications/presentation/controller/notifications_controller.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsController _controller;
  NotificationType? _filter;

  @override
  void initState() {
    super.initState();
    _controller = createNotificationsController();
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
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final items = _filtered(_controller.items);

        return Scaffold(
          appBar: AppBar(
            title: const Text('الإشعارات'),
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      _FilterChip(
                        label: 'الكل',
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'مهام',
                        selected: _filter == NotificationType.task,
                        onTap: () => setState(() => _filter = NotificationType.task),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'تقارير',
                        selected: _filter == NotificationType.report,
                        onTap: () => setState(() => _filter = NotificationType.report),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _NotificationTile(item: items[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<NotificationItemEntity> _filtered(List<NotificationItemEntity> items) {
    if (_filter == null) return items;
    return items.where((item) => item.type == _filter).toList();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(32),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected ? Colors.white : theme.colorScheme.primary,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationItemEntity item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = item.isUnread;

    return Card(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (item.type == NotificationType.task ? theme.colorScheme.primary : theme.colorScheme.secondary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.type == NotificationType.task ? Icons.assignment_outlined : Icons.description_outlined,
                  color: item.type == NotificationType.task ? theme.colorScheme.primary : theme.colorScheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold,
                              color: isUnread ? theme.colorScheme.primary : null,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 4),
                        Text(
                          item.timeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
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
