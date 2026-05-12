import 'package:flutter/material.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';
import 'package:inspector_app/features/tasks/presentation/controller/tasks_controller.dart';
import 'package:inspector_app/features/tasks/presentation/pages/task_details_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late final TasksController _controller;
  TaskStatus? _filter;

  @override
  void initState() {
    super.initState();
    _controller = createTasksController();
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
        final tasks = _filteredTasks(_controller.tasks);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('كل المهام'),
          ),
          body: _controller.isLoading && tasks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _FilterChip(
                          label: 'الكل',
                          selected: _filter == null,
                          onTap: () => setState(() => _filter = null),
                        ),
                        _FilterChip(
                          label: 'جارية',
                          selected: _filter == TaskStatus.inProgress,
                          onTap: () => setState(() => _filter = TaskStatus.inProgress),
                        ),
                        _FilterChip(
                          label: 'مُعادة',
                          selected: _filter == TaskStatus.returned,
                          onTap: () => setState(() => _filter = TaskStatus.returned),
                        ),
                        _FilterChip(
                          label: 'معلقة',
                          selected: _filter == TaskStatus.pending,
                          onTap: () => setState(() => _filter = TaskStatus.pending),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (final task in tasks) ...<Widget>[
                      _TaskTile(
                        task: task,
                        onTap: () => _openTaskDetails(task),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
        );
      },
    );
  }

  List<TaskEntity> _filteredTasks(List<TaskEntity> tasks) {
    if (_filter == null) return tasks;
    return tasks.where((task) => task.status == _filter).toList();
  }

  void _openTaskDetails(TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailsPage(taskId: task.id)),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? Theme.of(context).colorScheme.primary : null,
              ),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onTap});

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
          border: BorderDirectional(start: BorderSide(color: style.borderColor, width: 4)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                  const SizedBox(height: 4),
                  Text(
                    task.timeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            _StatusChip(label: style.label, color: style.labelColor),
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
