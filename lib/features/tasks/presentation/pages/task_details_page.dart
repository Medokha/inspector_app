import 'package:flutter/material.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_details_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_step_entity.dart';
import 'package:inspector_app/features/tasks/presentation/controller/task_details_controller.dart';
import 'package:inspector_app/features/tasks/presentation/pages/report_page.dart';

class TaskDetailsPage extends StatefulWidget {
  const TaskDetailsPage({super.key, required this.taskId});

  final String taskId;

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late final TaskDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = createTaskDetailsController();
    _controller.load(widget.taskId);
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
        final details = _controller.details;

        return Scaffold(
          appBar: AppBar(
            title: const Text('تفاصيل المهمة'),
          ),
          body: _controller.isLoading && details == null
              ? const Center(child: CircularProgressIndicator())
              : details == null
                  ? const Center(child: Text('تعذر تحميل المهمة'))
                  : _buildBody(context, details),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TaskDetailsEntity details) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          details.task.title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          details.task.location,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _InfoChip(label: details.code),
            _InfoChip(label: details.stageLabel),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'بيانات المهمة',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _InfoRow(label: 'الموعد', value: details.plannedDate),
              _InfoRow(label: 'حالة التنفيذ', value: details.stageLabel),
              _InfoRow(label: 'الوقت المتبقي', value: '٤ ساعات'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'مسار التنفيذ',
          child: Column(
            children: details.steps
                .map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _StepRow(step: step),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'موقع المهمة',
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(details.mapHint ?? 'اضغط لفتح الخريطة'),
            ),
          ),
        ),
        if (details.inspectorNote != null) ...<Widget>[
          const SizedBox(height: 16),
          _SectionCard(
            title: 'ملاحظات المفتش',
            child: Text(details.inspectorNote!),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportPage()),
            );
          },
          icon: const Icon(Icons.upload_file_outlined),
          label: const Text('رفع التقرير'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.map_outlined),
          label: const Text('فتح الخريطة'),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});

  final TaskStepEntity step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _StepStyle.fromStatus(step.status, theme);

    return Row(
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: style.dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            step.title,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          step.timeLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _StepStyle {
  const _StepStyle(this.dotColor);

  final Color dotColor;

  static _StepStyle fromStatus(TaskStepStatus status, ThemeData theme) {
    switch (status) {
      case TaskStepStatus.done:
        return _StepStyle(theme.colorScheme.primary);
      case TaskStepStatus.inProgress:
        return const _StepStyle(Color(0xFFF57C00));
      case TaskStepStatus.pending:
        return _StepStyle(theme.colorScheme.onSurface.withOpacity(0.3));
    }
  }
}
