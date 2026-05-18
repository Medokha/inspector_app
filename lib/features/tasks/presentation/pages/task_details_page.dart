import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/utils/map_launcher.dart';
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Premium Task Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoChip(label: details.code),
                    _StatusBadge(label: details.stageLabel, color: theme.colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  details.task.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.primary.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      details.task.location,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _SectionCard(
                  title: 'بيانات المهمة',
                  icon: Icons.assignment_outlined,
                  child: Column(
                    children: <Widget>[
                      _InfoRow(label: 'الموعد المخطط', value: details.plannedDate, icon: Icons.calendar_today),
                      // const Divider(height: 24),
                      // _InfoRow(label: 'الوقت المتبقي', value: '٤ ساعات', icon: Icons.timer_outlined, valueColor: theme.colorScheme.error),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'مسار التنفيذ',
                  icon: Icons.account_tree_outlined,
                  child: Column(
                    children: details.steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return _StepRow(
                        step: step,
                        isLast: index == details.steps.length - 1,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'الموقع الجغرافي',
                  icon: Icons.map_outlined,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (details.task.latitude != null && details.task.longitude != null)
                        ? GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(details.task.latitude!, details.task.longitude!),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(details.task.id),
                                position: LatLng(details.task.latitude!, details.task.longitude!),
                                infoWindow: InfoWindow(title: details.task.title),
                              ),
                            },
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_searching, color: theme.colorScheme.primary.withOpacity(0.3), size: 32),
                                const SizedBox(height: 12),
                                Text(
                                  'الموقع الجغرافي غير متوفر',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary.withOpacity(0.5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                if (details.inspectorNote != null) ...<Widget>[
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'ملاحظات إضافية',
                    icon: Icons.note_alt_outlined,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        details.inspectorNote!,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                if (_controller.isWithinRange) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ReportPage(taskId: widget.taskId)),
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.description_outlined),
                      label: const Text('بدء رفع التقرير الفني', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_off_outlined, color: theme.colorScheme.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'يجب أن تكون في موقع المهمة (على بعد أقل من ١٠٠ متر) لتتمكن من رفع التقرير.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _controller.checkProximity,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('تحديث المسافة'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: (details.task.latitude != null && details.task.longitude != null)
                        ? () => MapLauncher.launchNavigation(
                              latitude: details.task.latitude!,
                              longitude: details.task.longitude!,
                              title: details.task.title,
                            )
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.directions_rounded),
                    label: const Text('توجيه الملاحة', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

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
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isLast});

  final TaskStepEntity step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = step.status == TaskStepStatus.done;
    final isInProgress = step.status == TaskStepStatus.inProgress;
    
    final color = isDone ? theme.colorScheme.primary : (isInProgress ? const Color(0xFFF57C00) : theme.colorScheme.onSurface.withOpacity(0.2));

    return IntrinsicHeight(
      child: Row(
        children: <Widget>[
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    if (isInProgress)
                      BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, spreadRadius: 2),
                  ],
                ),
                child: isDone ? const Icon(Icons.check, size: 8, color: Colors.white) : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: (isDone || isInProgress) ? FontWeight.w900 : FontWeight.w500,
                    color: (isDone || isInProgress) ? null : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                if (step.timeLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.timeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
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
