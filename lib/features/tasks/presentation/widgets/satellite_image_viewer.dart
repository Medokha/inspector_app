import 'package:flutter/material.dart';

/// لقطة قمرية قابلة للضغط → ملء الشاشة مع تقريب/تبعيد حر.
class SatelliteImageViewer extends StatelessWidget {
  const SatelliteImageViewer({
    super.key,
    required this.url,
    this.label,
    this.height = 160,
  });

  final String url;
  final String? label;
  final double height;

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _SatelliteFullscreenPage(url: url, title: label ?? 'لقطة قمرية'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Text(label!, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
        ],
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openFullscreen(context),
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: <Widget>[
                  Image.network(
                    url,
                    height: height,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => SizedBox(
                      height: height,
                      child: const Center(child: Text('تعذر عرض اللقطة')),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.fullscreen, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'ملء الشاشة',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SatelliteFullscreenPage extends StatefulWidget {
  const _SatelliteFullscreenPage({required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<_SatelliteFullscreenPage> createState() => _SatelliteFullscreenPageState();
}

class _SatelliteFullscreenPageState extends State<_SatelliteFullscreenPage> {
  final _controller = TransformationController();
  static const _min = 0.8;
  static const _max = 8.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomBy(double factor) {
    final current = _controller.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(_min, _max);
    _controller.value = Matrix4.identity()..scale(next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(onPressed: () => _zoomBy(0.8), icon: const Icon(Icons.zoom_out)),
          IconButton(onPressed: () => _zoomBy(1.25), icon: const Icon(Icons.zoom_in)),
          IconButton(
            onPressed: () => _controller.value = Matrix4.identity(),
            icon: const Icon(Icons.fit_screen),
            tooltip: 'إعادة الضبط',
          ),
        ],
      ),
      body: InteractiveViewer(
        transformationController: _controller,
        minScale: _min,
        maxScale: _max,
        panEnabled: true,
        scaleEnabled: true,
        child: Center(
          child: Image.network(
            widget.url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'تعذر تحميل اللقطة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
