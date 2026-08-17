import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:inspector_app/features/tasks/presentation/widgets/satellite_tiles.dart';
import 'package:latlong2/latlong.dart';

/// خريطة قمرية بملء الشاشة مع تقريب/تبعيد حر والتقاط اللقطة الحالية.
class SatelliteMapFullscreenPage extends StatefulWidget {
  const SatelliteMapFullscreenPage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.title = 'القمر الصناعي',
    this.enableCapture = true,
  });

  final double latitude;
  final double longitude;
  final String title;
  final bool enableCapture;

  @override
  State<SatelliteMapFullscreenPage> createState() => _SatelliteMapFullscreenPageState();
}

class _SatelliteMapFullscreenPageState extends State<SatelliteMapFullscreenPage> {
  final _mapController = MapController();
  final _captureKey = GlobalKey();
  double _zoom = SatelliteTiles.defaultZoom;
  bool _capturing = false;

  LatLng get _point => LatLng(widget.latitude, widget.longitude);

  void _setZoom(double next) {
    final z = next.clamp(SatelliteTiles.minZoom, SatelliteTiles.maxZoom);
    setState(() => _zoom = z);
    _mapController.move(_mapController.camera.center, z);
  }

  Future<void> _captureView() async {
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('تعذر التقاط الخريطة');
      }
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) {
        throw Exception('تعذر ترميز الصورة');
      }
      if (!mounted) return;
      Navigator.of(context).pop(bytes.buffer.asUint8List());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التقاط الصورة: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: widget.enableCapture
            ? <Widget>[
                TextButton.icon(
                  onPressed: _capturing ? null : _captureView,
                  icon: _capturing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.camera_alt_outlined, color: Colors.white),
                  label: Text(
                    _capturing ? 'جاري الالتقاط...' : 'التقاط',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ]
            : null,
      ),
      body: Stack(
        children: <Widget>[
          RepaintBoundary(
            key: _captureKey,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _point,
                initialZoom: _zoom,
                minZoom: SatelliteTiles.minZoom,
                maxZoom: SatelliteTiles.maxZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onPositionChanged: (camera, _) {
                  if ((camera.zoom - _zoom).abs() > 0.05) {
                    setState(() => _zoom = camera.zoom);
                  }
                },
              ),
              children: <Widget>[
                TileLayer(
                  urlTemplate: SatelliteTiles.googleUrl,
                  subdomains: SatelliteTiles.googleSubdomains,
                  userAgentPackageName: 'iq.gov.swa.inspector',
                  maxNativeZoom: SatelliteTiles.nativeZoom,
                  maxZoom: SatelliteTiles.maxZoom,
                ),
                MarkerLayer(
                  markers: <Marker>[
                    Marker(
                      point: _point,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_on, color: Color(0xFFAF9748), size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 28,
            child: Column(
              children: <Widget>[
                _ZoomFab(icon: Icons.add, onTap: () => _setZoom(_zoom + 0.7)),
                const SizedBox(height: 10),
                _ZoomFab(icon: Icons.remove, onTap: () => _setZoom(_zoom - 0.7)),
                const SizedBox(height: 10),
                _ZoomFab(
                  icon: Icons.my_location,
                  onTap: () {
                    _mapController.move(_point, SatelliteTiles.defaultZoom);
                    setState(() => _zoom = SatelliteTiles.defaultZoom);
                  },
                ),
                if (widget.enableCapture) ...<Widget>[
                  const SizedBox(height: 10),
                  IgnorePointer(
                    ignoring: _capturing,
                    child: Opacity(
                      opacity: _capturing ? 0.45 : 1,
                      child: _ZoomFab(icon: Icons.camera_alt, onTap: _captureView),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            left: 12,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.enableCapture
                    ? 'تقريب ${_zoom.toStringAsFixed(1)}  ·  قرّب ثم اضغط التقاط'
                    : 'تقريب ${_zoom.toStringAsFixed(1)}  ·  اسحب وقرّب بإصبعين',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomFab extends StatelessWidget {
  const _ZoomFab({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF202D45),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
