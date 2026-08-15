import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/theme/app_theme.dart';
import 'package:inspector_app/core/ui/screen_insets.dart';
import 'package:inspector_app/features/route_map/domain/entities/route_stop_entity.dart';
import 'package:inspector_app/features/route_map/presentation/controller/route_controller.dart';
import 'package:inspector_app/features/route_map/presentation/pages/route_map_fullscreen_page.dart';
import 'package:inspector_app/features/route_map/presentation/widgets/route_stops_map.dart';
import 'package:inspector_app/features/tasks/presentation/pages/task_details_page.dart';

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

  Future<void> _openStop(RouteStopEntity stop) async {
    final id = stop.taskId;
    if (id == null || id.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailsPage(taskId: id)),
    );
    if (mounted) await _controller.load();
  }

  Future<void> _openFullscreenMap() async {
    await openRouteMapFullscreen(context, stops: _controller.stops);
    if (mounted) await _controller.load();
  }

  Future<void> _openGoogleDirections() async {
    final located = _controller.stops.where((s) => s.hasLocation).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    if (located.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد مواقع لفتح الاتجاهات'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final path = located.map((s) => '${s.latitude},${s.longitude}').join('/');
    final uri = Uri.parse('https://www.google.com/maps/dir/$path');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح خرائط Google'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final stops = _controller.stops;
        final hasMap = stops.any((s) => s.hasLocation);
        return Scaffold(
          appBar: AppBar(
            title: const Text('مساري اليوم'),
            actions: <Widget>[
              if (hasMap)
                IconButton(
                  tooltip: 'فتح خريطة المسار',
                  onPressed: _openFullscreenMap,
                  icon: const Icon(Icons.map_rounded),
                ),
              IconButton(
                tooltip: 'تحديث',
                onPressed: _controller.isLoading ? null : _controller.load,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: _controller.isLoading && stops.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _controller.load,
                  child: ListView(
                    padding: ScreenInsets.list(context, horizontal: 20, top: 16, extraBottom: 32),
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.sort_rounded, color: theme.colorScheme.secondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'الترتيب تلقائي من النظام حسب موعد الاستحقاق الذي تحدده الإدارة عند إنشاء المهمة — الأقرب موعدًا يظهر أولًا (1، 2، 3…).',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: hasMap ? _openFullscreenMap : null,
                        child: RouteStopsMap(
                          stops: stops,
                          onStopTap: _openStop,
                          onOpenFullscreen: hasMap ? _openFullscreenMap : null,
                        ),
                      ),
                      if (hasMap) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _openFullscreenMap,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.primaryNavy,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                icon: const Icon(Icons.fullscreen_rounded),
                                label: const Text('فتح خريطة المسار'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _openGoogleDirections,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                icon: const Icon(Icons.directions_rounded),
                                label: const Text('Google Maps'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'ترتيب الزيارات',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${stops.length}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الخط الذهبي يربط المواقع بنفس ترتيب القائمة أدناه.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (stops.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'لا توجد مهام على مسار اليوم',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        )
                      else
                        for (final stop in stops) ...<Widget>[
                          _RouteStopCard(
                            stop: stop,
                            onTap: () => _openStop(stop),
                          ),
                          const SizedBox(height: 12),
                        ],
                      const SizedBox(height: 16),
                      _RouteSummary(stopCount: stops.length),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _RouteStopCard extends StatelessWidget {
  const _RouteStopCard({required this.stop, this.onTap});

  final RouteStopEntity stop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _RouteStopStyle.fromStatus(stop.status, theme);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${stop.order}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      stop.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(
                          stop.timeLabel.isEmpty ? '—' : stop.timeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        if (stop.distanceLabel.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.place_outlined, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              stop.distanceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusChip(label: style.label, color: style.badgeColor),
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
        color: color.withValues(alpha: 0.1),
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

class _RouteSummary extends StatelessWidget {
  const _RouteSummary({required this.stopCount});

  final int stopCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.route_rounded, color: theme.colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stopCount <= 1
                  ? 'أضف أكثر من مهمة بإحداثيات اليوم لرؤية خط المسار بين المواقع'
                  : 'المسار يربط $stopCount مواقع بالترتيب — اضغط «فتح خريطة المسار» للعرض الكامل',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w800,
                height: 1.4,
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
        return const _RouteStopStyle(
          label: 'منتهية',
          badgeColor: Color(0xFF2E7D32),
          borderColor: Color(0xFF2E7D32),
        );
    }
  }
}
