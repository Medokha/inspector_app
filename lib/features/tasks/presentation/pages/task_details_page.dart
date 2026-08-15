import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/ui/responsive.dart';
import 'package:inspector_app/core/ui/screen_insets.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_details_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_step_entity.dart';
import 'package:inspector_app/features/tasks/presentation/controller/task_details_controller.dart';
import 'package:inspector_app/features/tasks/presentation/pages/report_page.dart';
import 'package:inspector_app/features/tasks/domain/quality/previous_visit_photo.dart';
import 'package:inspector_app/features/tasks/presentation/widgets/task_location_map_preview.dart';

class TaskDetailsPage extends StatefulWidget {
  const TaskDetailsPage({
    super.key,
    required this.taskId,
    this.autoStartTracking = false,
  });

  final String taskId;
  final bool autoStartTracking;

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late final TaskDetailsController _controller;
  bool _autoStartTried = false;

  @override
  void initState() {
    super.initState();
    _controller = createTaskDetailsController();
    _controller.addListener(_maybeAutoStart);
    _controller.load(widget.taskId);
  }

  void _maybeAutoStart() {
    if (_autoStartTried || !widget.autoStartTracking) return;
    final details = _controller.details;
    if (details == null || _controller.isLoading) return;
    _autoStartTried = true;
    if (details.canStart) {
      _controller.start(widget.taskId);
    } else if (details.isTracking) {
      // المهمة جارية بالفعل — التتبع يُستأنف من load
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeAutoStart);
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
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_controller.error ?? 'تعذر تحميل المهمة', textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => _controller.load(widget.taskId),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildBody(context, details),
        );
      },
    );
  }

  Future<void> _openNavigation(TaskDetailsEntity details) async {
    if (!details.hasLocation) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد إحداثيات جغرافية لهذه المهمة'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final lat = details.latitude!;
    final lng = details.longitude!;
    final uris = <Uri>[
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
      Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=16/$lat/$lng'),
      Uri.parse('geo:$lat,$lng?q=$lat,$lng'),
    ];

    for (final uri in uris) {
      try {
        final launched = await launchUrl(
          uri,
          mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
          webOnlyWindowName: kIsWeb ? '_blank' : null,
        );
        if (launched) return;
      } catch (_) {
        // جرّب الرابط التالي
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تعذر فتح تطبيق الخرائط'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showReportSheet(TaskDetailsEntity details) {
    final report = details.report;
    if (report == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              children: <Widget>[
                Text('التقرير المرفوع', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                _ReportField(label: 'الحالة العامة', value: report.generalCondition),
                _ReportField(label: 'درجة الجودة', value: '${report.qualityScore} / 5'),
                _ReportField(label: 'مخالفات', value: report.hasViolations ? 'نعم' : 'لا'),
                if (report.reportNotes != null && report.reportNotes!.isNotEmpty)
                  _ReportField(label: 'ملاحظات', value: report.reportNotes!),
                if (report.rejectionReason != null && report.rejectionReason!.isNotEmpty)
                  _ReportField(label: 'سبب الرفض', value: report.rejectionReason!, danger: true),
                if (report.photos.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    'المرفقات (${report.photos.length})',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: report.photos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final photo = report.photos[index];
                        if (photo.isPdf) {
                          return InkWell(
                            onTap: () => launchUrl(Uri.parse(photo.url), mode: LaunchMode.externalApplication),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.picture_as_pdf, color: theme.colorScheme.error, size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    photo.fileName ?? 'ملف PDF',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              photo.url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('لا توجد مرفقات'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TaskDetailsEntity details) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: ScreenInsets.bottom(context, extra: 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Premium Task Header
          Container(
            padding: EdgeInsets.fromLTRB(
              Responsive.pagePadding(context),
              24,
              Responsive.pagePadding(context),
              32,
            ),
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
                  children: [
                    Flexible(child: _InfoChip(label: details.code)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: _StatusBadge(label: details.stageLabel, color: theme.colorScheme.primary),
                      ),
                    ),
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
                    Expanded(
                      child: Text(
                        details.task.location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
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
                      _InfoRow(label: 'الموعد المخطط', value: details.plannedDate.isEmpty ? 'غير محدد' : details.plannedDate, icon: Icons.calendar_today),
                      const Divider(height: 24),
                      _InfoRow(
                        label: details.isOverdue ? 'حالة الموعد' : 'الوقت المتبقي',
                        value: details.remainingLabel,
                        icon: Icons.timer_outlined,
                        valueColor: details.isOverdue ? theme.colorScheme.error : null,
                      ),
                      if (details.description != null && details.description!.isNotEmpty) ...<Widget>[
                        const Divider(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            details.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                          ),
                        ),
                      ],
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
                if (details.auditTrail.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'سجل التدقيق',
                    icon: Icons.history_edu_outlined,
                    child: Column(
                      children: details.auditTrail.map((e) {
                        final when = e.at.millisecondsSinceEpoch == 0
                            ? '—'
                            : '${e.at.toLocal()}'.split('.').first;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.circle, size: 8, color: theme.colorScheme.secondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      e.summaryAr,
                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'بواسطة: ${e.performedBy} · $when',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'الموقع الجغرافي',
                  icon: Icons.map_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (details.hasLocation)
                        TaskLocationMapPreview(
                          latitude: details.latitude!,
                          longitude: details.longitude!,
                          onOpenExternal: () => _openNavigation(details),
                        )
                      else
                        Container(
                          height: 160,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.08)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              details.mapHint ?? 'لا توجد إحداثيات لهذه المهمة',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (details.hasLocation) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          'حرّك الخريطة للمعاينة، أو اضغط ملاحة للفتح في الخرائط',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (details.hasReport) ...<Widget>[
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'التقرير المرفوع',
                    icon: Icons.description_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _InfoRow(
                          label: 'الحالة العامة',
                          value: details.report!.generalCondition,
                          icon: Icons.fact_check_outlined,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'الجودة',
                          value: '${details.report!.qualityScore} / 5',
                          icon: Icons.star_outline,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'مخالفات',
                          value: details.report!.hasViolations ? 'نعم' : 'لا',
                          icon: Icons.warning_amber_outlined,
                          valueColor: details.report!.hasViolations ? theme.colorScheme.error : null,
                        ),
                        if (details.report!.photos.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 88,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: details.report!.photos.length.clamp(0, 6),
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final photo = details.report!.photos[index];
                                if (photo.isPdf) {
                                  return InkWell(
                                    onTap: () => launchUrl(
                                      Uri.parse(photo.url),
                                      mode: LaunchMode.externalApplication,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 88,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.picture_as_pdf, color: theme.colorScheme.error),
                                          const SizedBox(height: 4),
                                          Text(
                                            'PDF',
                                            style: theme.textTheme.labelSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.network(
                                      photo.url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        child: const Icon(Icons.image_not_supported_outlined),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () => _showReportSheet(details),
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('عرض التقرير بالكامل'),
                        ),
                      ],
                    ),
                  ),
                ],
                if (details.inspectorNote != null && !details.hasReport) ...<Widget>[
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'ملاحظات إضافية',
                    icon: Icons.note_alt_outlined,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        details.inspectorNote!,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ),
                  ),
                ],
                if (details.isTracking) ...<Widget>[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.share_location_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'التتبع يعمل — الإدارة ترى موقعك مباشرة على الخريطة',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                if (details.canStart)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _controller.isStarting
                          ? null
                          : () async {
                              final ok = await _controller.start(widget.taskId);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok ? 'تم بدء المهمة وبدأ التتبع' : (_controller.error ?? 'تعذر بدء المهمة')),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(_controller.isStarting ? 'جارٍ البدء...' : 'بدء المهمة والتتبع'),
                    ),
                  ),
                if (details.canStart) const SizedBox(height: 12),
                if (details.canSubmitReport)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final submitted = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => ReportPage(
                              taskId: widget.taskId,
                              taskTitle: details.task.title,
                              taskDescription: details.description,
                              previousPhotos: details.report?.photos
                                      .where((p) => !p.isPdf)
                                      .map(
                                        (p) => PreviousVisitPhoto(
                                          id: p.id,
                                          url: p.url,
                                          fileName: p.fileName,
                                          description: p.description,
                                        ),
                                      )
                                      .toList() ??
                                  const <PreviousVisitPhoto>[],
                            ),
                          ),
                        );
                        if (submitted == true) {
                          await _controller.load(widget.taskId);
                        }
                      },
                      icon: const Icon(Icons.description_outlined),
                      label: const Text('رفع التقرير الفني', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                if (details.canSubmitReport) const SizedBox(height: 12),
                if (details.hasReport) ...<Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _showReportSheet(details),
                      icon: const Icon(Icons.folder_open_outlined),
                      label: const Text('عرض التقرير المرفوع'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: details.hasLocation ? () => _openNavigation(details) : null,
                    icon: const Icon(Icons.directions_rounded),
                    label: Text(
                      details.hasLocation ? 'توجيه الملاحة' : 'لا توجد إحداثيات',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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

class _ReportField extends StatelessWidget {
  const _ReportField({
    required this.label,
    required this.value,
    this.danger = false,
  });

  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: danger ? theme.colorScheme.error : null,
              height: 1.4,
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
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
