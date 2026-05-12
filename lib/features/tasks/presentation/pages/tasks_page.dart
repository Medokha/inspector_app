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
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final tasks = _filteredTasks(_controller.tasks);

        return Scaffold(
          appBar: AppBar(
            title: const Text('كل المهام'),
          ),
          body: _controller.isLoading && tasks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                              label: 'جارية',
                              selected: _filter == TaskStatus.inProgress,
                              onTap: () => setState(() => _filter = TaskStatus.inProgress),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'مُعادة',
                              selected: _filter == TaskStatus.returned,
                              onTap: () => setState(() => _filter = TaskStatus.returned),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'معلقة',
                              selected: _filter == TaskStatus.pending,
                              onTap: () => setState(() => _filter = TaskStatus.pending),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'منتهية',
                              selected: _filter == TaskStatus.completed,
                              onTap: () => setState(() => _filter = TaskStatus.completed),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _TaskTile(
                            task: tasks[index],
                            onTap: () => _openTaskDetails(tasks[index]),
                          );
                        },
                      ),
                    ),
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

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onTap});

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
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          task.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 4),
                        Text(
                          task.timeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusChip(label: style.label, color: style.labelColor),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
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
