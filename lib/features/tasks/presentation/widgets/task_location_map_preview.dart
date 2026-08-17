import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:inspector_app/features/tasks/presentation/widgets/satellite_tiles.dart';
import 'package:latlong2/latlong.dart';

/// معاينة خريطة حية لموقع المهمة (شارع أو قمر صناعي).
class TaskLocationMapPreview extends StatelessWidget {
  const TaskLocationMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.onOpenExternal,
    this.onOpenFullscreen,
    this.height = 220,
    this.useSatellite = false,
  });

  final double latitude;
  final double longitude;
  final VoidCallback? onOpenExternal;
  final VoidCallback? onOpenFullscreen;
  final double height;
  final bool useSatellite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final point = LatLng(latitude, longitude);
    final primary = theme.colorScheme.primary;
    final gold = const Color(0xFFAF9748);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: useSatellite ? SatelliteTiles.defaultZoom : 16.2,
                minZoom: useSatellite ? SatelliteTiles.minZoom : 12,
                maxZoom: useSatellite ? SatelliteTiles.maxZoom : 19,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.pinchMove |
                      InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.scrollWheelZoom |
                      InteractiveFlag.flingAnimation,
                ),
              ),
              children: <Widget>[
                TileLayer(
                  urlTemplate: useSatellite
                      ? SatelliteTiles.googleUrl
                      : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: useSatellite
                      ? SatelliteTiles.googleSubdomains
                      : const <String>['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'iq.gov.swa.inspector',
                  retinaMode: useSatellite ? false : RetinaMode.isHighDensity(context),
                  maxNativeZoom: useSatellite ? SatelliteTiles.nativeZoom : 20,
                  maxZoom: useSatellite ? SatelliteTiles.maxZoom : 20,
                ),
                CircleLayer(
                  circles: <CircleMarker>[
                    CircleMarker(
                      point: point,
                      radius: 42,
                      useRadiusInMeter: false,
                      color: gold.withValues(alpha: 0.18),
                      borderColor: gold.withValues(alpha: 0.45),
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: <Marker>[
                    Marker(
                      point: point,
                      width: 48,
                      height: 56,
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.location_on, color: Color(0xFFAF9748), size: 22),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  useSatellite ? '© صور الأقمار — قرّب بإصبعين' : '© OpenStreetMap © CARTO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.black54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE8E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.place, size: 14, color: primary),
                    const SizedBox(width: 4),
                    Text(
                      'موقع المهمة',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (onOpenFullscreen != null)
                    Material(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                      elevation: 2,
                      child: InkWell(
                        onTap: onOpenFullscreen,
                        borderRadius: BorderRadius.circular(999),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.fullscreen, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'ملء الشاشة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (onOpenFullscreen != null && onOpenExternal != null) const SizedBox(height: 8),
                  if (onOpenExternal != null)
                    Material(
                      color: primary,
                      borderRadius: BorderRadius.circular(999),
                      elevation: 2,
                      child: InkWell(
                        onTap: onOpenExternal,
                        borderRadius: BorderRadius.circular(999),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.directions, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'ملاحة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
