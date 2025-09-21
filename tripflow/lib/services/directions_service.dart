import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class DirectionsService {
  static Future<void> openWalkingDirections({
    required double latitude,
    required double longitude,
    String? placeName,
  }) async {
    final encodedName = Uri.encodeComponent(placeName ?? 'Destination');

    // 1) Naver Maps (if installed)
    final naverUri = Uri.parse(
      'nmap://route/walk?dlat=$latitude&dlng=$longitude&dname=$encodedName',
    );
    if (await canLaunchUrl(naverUri)) {
      if (await launchUrl(naverUri, mode: LaunchMode.externalApplication)) return;
    }

    // 2) Google Maps app (if installed)
    final googleAppUri = Uri.parse('comgooglemaps://?daddr=$latitude,$longitude&directionsmode=walking');
    if (await canLaunchUrl(googleAppUri)) {
      if (await launchUrl(googleAppUri, mode: LaunchMode.externalApplication)) return;
    }

    // 3) Google Maps web (fallback)
    final googleWebUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=walking');
    await launchUrl(googleWebUri, mode: LaunchMode.externalApplication);
  }
}
