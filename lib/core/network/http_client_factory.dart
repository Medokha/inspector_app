import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createHttpClient() {
  if (kIsWeb) {
    return http.Client();
  }

  final ioClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8)
    ..idleTimeout = const Duration(seconds: 15);

  if (kDebugMode) {
    ioClient.badCertificateCallback = (cert, host, port) => true;
  }

  return IOClient(ioClient);
}
