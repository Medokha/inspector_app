import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:inspector_app/core/theme/app_theme.dart';
import 'package:inspector_app/features/route_map/domain/entities/route_stop_entity.dart';

/// خريطة مسار اليوم: نقاط مرقّمة + خط يربط بينها حسب ترتيب الزيارة.
class RouteStopsMap extends StatefulWidget {
  const RouteStopsMap({
    super.key,
    required this.stops,
    this.height = 280,
    this.expand = false,
    this.onStopTap,
    this.onOpenFullscreen,
  });

  final List<RouteStopEntity> stops;
  final double height;
  /// عند true تملأ المساحة المتاحة (لشاشة الخريطة الكاملة).
  final bool expand;
  final ValueChanged<RouteStopEntity>? onStopTap;
  final VoidCallback? onOpenFullscreen;

  @override
  State<RouteStopsMap> createState() => _RouteStopsMapState();
}

class _RouteStopsMapState extends State<RouteStopsMap> {
  final MapController _mapController = MapController();

  List<RouteStopEntity> get _located =>
      widget.stops.where((s) => s.hasLocation).toList()..sort((a, b) => a.order.compareTo(b.order));

  List<LatLng> get _points =>
      _located.map((s) => LatLng(s.latitude!, s.longitude!)).toList();

  @override
  void didUpdateWidget(covariant RouteStopsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stops != widget.stops) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
  }

  void _fitBounds() {
    final points = _points;
    if (!mounted || points.isEmpty) return;
    try {
      if (points.length == 1) {
        _mapController.move(points.first, 14.5);
        return;
      }
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = _points;
    final located = _located;

    if (points.isEmpty) {
      final empty = Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.map_outlined, size: 40, color: theme.colorScheme.primary.withValues(alpha: 0.45)),
            const SizedBox(height: 10),
            Text(
              'لا توجد مواقع على المسار اليوم',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'أضف مهام بإحداثيات واستحقاق اليوم',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
      return widget.expand ? empty : SizedBox(height: widget.height, child: empty);
    }

    final center = points.length == 1
        ? points.first
        : LatLng(
            points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length,
            points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length,
          );

    final mapStack = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: points.length == 1 ? 14.5 : 12.2,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              subdomains: const <String>['a', 'b', 'c', 'd'],
              userAgentPackageName: 'iq.gov.swa.inspector',
              retinaMode: RetinaMode.isHighDensity(context),
            ),
            if (points.length > 1)
              PolylineLayer(
                polylines: <Polyline>[
                  Polyline(
                    points: points,
                    color: AppTheme.accentGold.withValues(alpha: 0.35),
                    strokeWidth: 8,
                  ),
                  Polyline(
                    points: points,
                    color: AppTheme.accentGold,
                    strokeWidth: 4,
                    borderStrokeWidth: 1,
                    borderColor: Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ),
            MarkerLayer(
              markers: <Marker>[
                for (final stop in located)
                  Marker(
                    point: LatLng(stop.latitude!, stop.longitude!),
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => widget.onStopTap?.call(stop),
                      child: _StopPin(
                        order: stop.order,
                        status: stop.status,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              '${located.length} توقف · حسب موعد الاستحقاق',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryNavy,
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.onOpenFullscreen != null) ...[
                Material(
                  color: AppTheme.accentGold,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onOpenFullscreen,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.fullscreen_rounded, color: AppTheme.primaryNavy, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Material(
                color: AppTheme.primaryNavy,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _fitBounds,
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.fit_screen_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.expand ? 20 : 24),
      child: widget.expand
          ? mapStack
          : SizedBox(height: widget.height, width: double.infinity, child: mapStack),
    );
  }
}

class _StopPin extends StatelessWidget {
  const _StopPin({required this.order, required this.status});

  final int order;
  final RouteStopStatus status;

  Color get _color {
    switch (status) {
      case RouteStopStatus.inProgress:
        return const Color(0xFFF57C00);
      case RouteStopStatus.completed:
        return const Color(0xFF2E7D32);
      case RouteStopStatus.pending:
        return AppTheme.primaryNavy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '$order',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }
}
