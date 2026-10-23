/// فك ضغط gzip حسب المنصة: zlib الأصلي (dart:io) على المنصات الأصلية —
/// أسرع بكثير من فاك الضغط المكتوب بـ Dart خالص — و`archive` على الويب.
///
/// Platform gunzip: native zlib via dart:io where available, `archive` on web.
library;

export 'gzip_bytes_stub.dart' if (dart.library.io) 'gzip_bytes_io.dart'
    show gunzipBytes;
