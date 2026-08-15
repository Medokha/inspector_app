import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class MapLauncher {
  static Future<void> launchNavigation({
    required double latitude,
    required double longitude,
    String? title,
  }) async {
    // 1. If it's running on Web
    if (kIsWeb) {
      final Uri webUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
      );
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // 2. If running on iOS (Native)
    if (Platform.isIOS) {
      final Uri appleMapsUrl = Uri.parse(
        'https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d',
      );
      final Uri googleMapsUrl = Uri.parse(
        'comgooglemaps://?daddr=$latitude,$longitude&directionsmode=driving',
      );

      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
        return;
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl);
        return;
      }
    }

    // 3. If running on Android (Native)
    if (Platform.isAndroid) {
      final Uri googleMapsAndroidUrl = Uri.parse(
        'google.navigation:q=$latitude,$longitude&mode=d',
      );
      if (await canLaunchUrl(googleMapsAndroidUrl)) {
        await launchUrl(googleMapsAndroidUrl);
        return;
      }
    }

    // 4. Default Fallback for other platforms or if native schemes fail
    final Uri googleMapsWebUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );
    if (await canLaunchUrl(googleMapsWebUrl)) {
      await launchUrl(googleMapsWebUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch map';
    }
  }
}
