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
    _controller.startListeningToNotifications();
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
        final overview = _controller.overview;
        if (_controller.isLoading && overview == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.error != null && overview == null) {
          return const Center(child: Text('تعذر تحميل البيانات'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header Section - Re-imagined for an eye-catching airy look
              Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary, // Using the lighter mint teal
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(48),
                    bottomRight: Radius.circular(48),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _HeaderSection(
                        name: overview?.inspectorName ?? 'المفتش',
                        region: overview?.region ?? 'المنطقة',
                        unreadCount: overview?.unreadNotifications ?? 0,
                        onOpenNotifications: widget.onOpenNotifications,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _StatCard(
                              label: 'مهام اليوم',
                              value: (overview?.totalToday ?? 0).toString(),
                              icon: Icons.calendar_month_rounded,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _StatCard(
                              label: 'المُعادة',
                              value: (overview?.returnedCount ?? 0).toString(),
                              icon: Icons.assignment_return_rounded,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المهام الجارية',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        TextButton(
                          onPressed: () => widget.onNavigateToTab(1),
                          child: Row(
                            children: [
                              Text('الكل', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (overview?.activeTasks.isEmpty ?? true)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.assignment_turned_in_outlined,
                                size: 64,
                                color: theme.colorScheme.primary.withOpacity(0.1),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد مهام جارية',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      for (final task in overview?.activeTasks ?? <TaskEntity>[]) ...<Widget>[
                        _TaskCard(
                          task: task,
                          onTap: () => _openTaskDetails(task),
                        ),
                        const SizedBox(height: 12),
                      ],
                    
                    const SizedBox(height: 32),
                    Text(
                      'الإشعارات الأخيرة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: overview?.recentNotifications.length ?? 0,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: theme.colorScheme.onSurface.withOpacity(0.05),
                        ),
                        itemBuilder: (context, index) {
                          final notification = overview!.recentNotifications[index];
                          return InkWell(
                            onTap: () async {
                              if (notification.isUnread) {
                                final notifyController = createNotificationsController();
                                await notifyController.markAsRead(notification.id);
                                _controller.load(); // Refresh home
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: _NotificationRow(
                                title: notification.title,
                                timeLabel: notification.timeLabel,
                                isUnread: notification.isUnread,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'مرحباً بك،',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onOpenNotifications,
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
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
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 32,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
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

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _StatusChip(label: style.label, color: style.labelColor),
                  const Spacer(),
                  Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text(
                    task.timeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                task.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      task.location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (task.rejectionReason != null) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.error.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.rejectionReason!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
