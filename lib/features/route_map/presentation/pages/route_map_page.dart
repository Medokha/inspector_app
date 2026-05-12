import 'package:flutter/material.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/features/route_map/domain/entities/route_stop_entity.dart';
import 'package:inspector_app/features/route_map/presentation/controller/route_controller.dart';

class RouteMapPage extends StatefulWidget {
  const RouteMapPage({super.key});

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  late final RouteController _controller;

  @override
  void initState() {
    super.initState();
    _controller = createRouteController();
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('مساري اليوم'),
          ),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    _MapPlaceholder(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'ترتيب الزيارات المقترح',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '١',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final stop in _controller.stops) ...<Widget>[
                      _RouteStopCard(stop: stop),
                      const SizedBox(height: 12),
                    ],
                    _RouteSummary(),
                  ],
                ),
        );
      },
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text('خريطة المسار')),
    );
  }
}

class _RouteStopCard extends StatelessWidget {
  const _RouteStopCard({required this.stop});

  final RouteStopEntity stop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _RouteStopStyle.fromStatus(stop.status, theme);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: BorderDirectional(start: BorderSide(color: style.borderColor, width: 4)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: style.badgeColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text('${stop.order}', style: theme.textTheme.bodySmall),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  stop.title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  stop.timeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(label: style.label, color: style.badgeColor),
        ],
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

class _RouteSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'المسار يحسن توفير الوقت والمسافة',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF2E7D32),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStopStyle {
  const _RouteStopStyle({required this.label, required this.badgeColor, required this.borderColor});

  final String label;
  final Color badgeColor;
  final Color borderColor;

  static _RouteStopStyle fromStatus(RouteStopStatus status, ThemeData theme) {
    switch (status) {
      case RouteStopStatus.inProgress:
        return const _RouteStopStyle(
          label: 'جارية',
          badgeColor: Color(0xFFF57C00),
          borderColor: Color(0xFFF57C00),
        );
      case RouteStopStatus.pending:
        return const _RouteStopStyle(
          label: 'معلقة',
          badgeColor: Color(0xFF1565C0),
          borderColor: Color(0xFF90A4AE),
        );
      case RouteStopStatus.completed:
        return _RouteStopStyle(
          label: 'منتهية',
          badgeColor: const Color(0xFF2E7D32),
          borderColor: const Color(0xFF2E7D32),
        );
    }
  }
}
