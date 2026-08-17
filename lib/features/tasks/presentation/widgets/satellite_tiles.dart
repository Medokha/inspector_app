/// طبقات صور قمرية للعرض التفاعلي.
/// Esri عند الزووم العالي في العراق يعرض "Map data not yet available"،
/// لذلك نستخدم صور Google Satellite للتقريب القريب.
class SatelliteTiles {
  SatelliteTiles._();

  static const googleUrl =
      'https://mt{s}.google.com/vt/lyrs=s&hl=ar&x={x}&y={y}&z={z}';
  static const googleSubdomains = <String>['0', '1', '2', '3'];
  static const esriUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  static const minZoom = 12.0;
  static const maxZoom = 20.0;
  static const nativeZoom = 20;
  static const defaultZoom = 18.0;
}
