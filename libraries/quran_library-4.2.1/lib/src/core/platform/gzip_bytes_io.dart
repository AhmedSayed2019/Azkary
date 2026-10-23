import 'dart:io' show gzip;
import 'dart:typed_data' show Uint8List;

/// فك ضغط gzip عبر zlib الأصلي.
Uint8List gunzipBytes(List<int> gzBytes) {
  final out = gzip.decode(gzBytes);
  return out is Uint8List ? out : Uint8List.fromList(out);
}
