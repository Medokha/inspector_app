import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/utils/map_launcher.dart';
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
    final theme = Theme.of(context);
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: <Widget>[
                    _InteractiveMap(stops: _controller.stops),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'ترتيب الزيارات المقترح',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '١', // Route ID or sequence
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (final stop in _controller.stops) ...<Widget>[
                      _RouteStopCard(stop: stop),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 24),
                    _RouteSummary(),
                    const SizedBox(height: 32),
                  ],
                ),
        );
      },
    );
  }
}

class _InteractiveMap extends StatelessWidget {
  const _InteractiveMap({required this.stops});

  final List<RouteStopEntity> stops;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Filter valid coordinates
    final validStops = stops.where((s) => s.latitude != null && s.longitude != null).toList();
    
    if (validStops.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text('المواقع غير متوفرة حالياً', style: TextStyle(color: theme.colorScheme.primary)),
        ),
      );
    }

    final markers = validStops.map((stop) {
      return Marker(
        markerId: MarkerId(stop.taskId),
        position: LatLng(stop.latitude!, stop.longitude!),
        infoWindow: InfoWindow(title: stop.title, snippet: 'ترتيب الزيارة: ${stop.order}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          stop.status == RouteStopStatus.inProgress ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueAzure,
        ),
      );
    }).toSet();

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(validStops.first.latitude!, validStops.first.longitude!),
          zoom: 12,
        ),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      ),
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

    return Card(
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
                    color: theme.colorScheme.primary.withOpacity(0.2),
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
                      Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text(
                        stop.timeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusChip(label: style.label, color: style.badgeColor),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: (stop.latitude != null && stop.longitude != null)
                  ? () => MapLauncher.launchNavigation(
                        latitude: stop.latitude!,
                        longitude: stop.longitude!,
                        title: stop.title,
                      )
                  : null,
              icon: const Icon(Icons.directions_rounded, size: 20),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(40, 40),
              ),
            ),
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

class _RouteSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.stars, color: theme.colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'المسار يحسن توفير الوقت والمسافة بناءً على بيانات المرور الحالية',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w900,
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
        return _RouteStopStyle(
          label: 'منتهية',
          badgeColor: const Color(0xFF2E7D32),
          borderColor: const Color(0xFF2E7D32),
        );
    }
  }
}
