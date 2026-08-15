import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:inspector_app/core/theme/app_theme.dart';
import 'package:inspector_app/features/route_map/domain/entities/route_stop_entity.dart';
import 'package:inspector_app/features/route_map/presentation/widgets/route_stops_map.dart';
import 'package:inspector_app/features/tasks/presentation/pages/task_details_page.dart';

/// خريطة المسار بملء الشاشة مع إمكانية فتح الاتجاهات في Google Maps.
class RouteMapFullscreenPage extends StatelessWidget {
  const RouteMapFullscreenPage({
    super.key,
    required this.stops,
    this.onStopTap,
  });

  final List<RouteStopEntity> stops;
  final ValueChanged<RouteStopEntity>? onStopTap;

  Future<void> _openGoogleDirections(BuildContext context) async {
    final located = stops.where((s) => s.hasLocation).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    if (located.isEmpty) return;

    final path = located.map((s) => '${s.latitude},${s.longitude}').join('/');
    final uri = Uri.parse('https://www.google.com/maps/dir/$path');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح خرائط جوجل'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locatedCount = stops.where((s) => s.hasLocation).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة المسار'),
        actions: <Widget>[
          if (locatedCount > 0)
            IconButton(
              tooltip: 'فتح في خرائط جوجل',
              onPressed: () => _openGoogleDirections(context),
              icon: const Icon(Icons.open_in_new_rounded),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.25)),
              ),
              child: Text(
                'الترتيب تلقائي حسب موعد الاستحقاق الذي تحدده الإدارة عند إنشاء المهمة (الأقرب موعدًا أولًا).',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: RouteStopsMap(
                stops: stops,
                height: double.infinity,
                expand: true,
                onStopTap: onStopTap,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: locatedCount == 0 ? null : () => _openGoogleDirections(context),
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('اتجاهات جوجل'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('تم'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> openRouteMapFullscreen(
  BuildContext context, {
  required List<RouteStopEntity> stops,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => RouteMapFullscreenPage(
        stops: stops,
        onStopTap: (stop) {
          final id = stop.taskId;
          if (id == null || id.isEmpty) return;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TaskDetailsPage(taskId: id)),
          );
        },
      ),
    ),
  );
}
