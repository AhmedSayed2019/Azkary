import 'dart:typed_data' show Uint8List;

import 'package:archive/archive.dart' show GZipDecoder;

/// فك ضغط gzip بـ Dart خالص (الويب: لا يوجد dart:io).
Uint8List gunzipBytes(List<int> gzBytes) {
  return const GZipDecoder().decodeBytes(gzBytes);
}
