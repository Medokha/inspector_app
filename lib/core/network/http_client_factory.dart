import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createHttpClient() {
  if (kIsWeb) {
    return http.Client();
  }

  final ioClient = HttpClient();

  if (kDebugMode) {
    ioClient.badCertificateCallback = (cert, host, port) {
      final isDevHost = host == 'localhost' || host == '10.0.2.2' || host == '127.0.0.1';
      return isDevHost;
    };
  }

  return IOClient(ioClient);
}
