import 'package:flutter/material.dart';
import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/features/profile/presentation/controller/reports_controller.dart';
import 'package:inspector_app/features/profile/domain/entities/report_item.dart';

class ReportsListPage extends StatefulWidget {
  const ReportsListPage({super.key});

  @override
  State<ReportsListPage> createState() => _ReportsListPageState();
}

class _ReportsListPageState extends State<ReportsListPage> {
  late final ReportsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = createReportsController();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('كافة التقارير'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text('لا توجد تقارير مرفوعة حالياً'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _controller.reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _ReportTile(item: _controller.reports[index]);
            },
          );
        },
      ),
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

    return Card(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.description_outlined, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.dateLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusBadge(label: status.label, color: status.color),
            ],
          ),
        ),
      ),
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
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
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
