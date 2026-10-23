part of '/quran.dart';

/// خدمة تحميل كسول (lazy) وتسجيل خطوط QCF4 المضغوطة (tajweed).
///
/// الخطوط مخزّنة كملفات `.ttf.gz` في assets. عند الحاجة يتم فك ضغطها
/// وتسجيلها عبر [loadFontFromList]. تُحفظ النسخ المفكوكة على القرص
/// (على المنصات غير الويب) لتسريع التشغيلات اللاحقة.
///
/// **التحميل الكسول**: تُحمّل فقط الصفحات القريبة من الصفحة الحالية،
/// ثم تُكمَل بقية الصفحات في الخلفية تدريجيًا.
class QuranFontsService {
  QuranFontsService._();

  static const int _totalPages = 604;

  /// متغيرات الخط المسجّلة لكل صفحة (1-based): لاحقة اسم العائلة
  /// ('' فاتح بتجويد، 'd' داكن بتجويد، 'n' فاتح بلا تجويد، 'nd' داكن بلا
  /// تجويد، 'nr' أحمر للخلاف).
  ///
  /// كان كل تحميل صفحة يسجّل المتغيرات الخمسة دفعة واحدة، وكل
  /// [loadFontFromList] يعيد تخطيط كل نصوص التطبيق ويحجز ذاكرة أصلية لا
  /// تُحرَّر. الآن يُسجَّل المتغير المطلوب للإعدادات الحالية فقط، ويُسجَّل غيره
  /// كسولًا حين يتغير الوضع الداكن/التجويد/القراءات العشر.
  static final Map<int, Set<String>> _registered = {};

  /// Futures لمنع تكرار تسجيل نفس المتغير لنفس الصفحة عند الاستدعاء المتزامن.
  static final Map<String, Future<void>> _variantLoadFutures = {};

  /// Futures لمنع تكرار قراءة/فك ضغط نفس الصفحة.
  static final Map<int, Future<Uint8List>> _baseBytesFutures = {};

  /// كاش LRU صغير لبايتات الخط الأصلية (المفكوكة) للصفحات القريبة، لتسجيل
  /// متغير جديد عند تغيّر الإعدادات دون إعادة القراءة/فك الضغط.
  static final Map<int, Uint8List> _baseBytesCache = {};
  static const int _maxBaseBytesCache = 12;

  /// آخر قيمة معروفة للوضع الداكن (تُحدَّث من [isPageReady]/[ensurePagesLoaded]
  /// و[FontsExtension.getFontPath]) — للمستدعين الذين لا يعرفونها.
  static bool _lastIsDark =
      PlatformDispatcher.instance.platformBrightness == Brightness.dark;

  /// صفحات طُلب لها متغير غير مسجّل أثناء البناء وجُدول تسجيله.
  static final Set<int> _pendingVariantPages = {};

  /// Future واحد لتحميل الخلفية لمنع التكرار.
  static Future<void>? _backgroundLoadFuture;

  /// كاش مجلد الخطوط المفكوكة (يُهيّأ مرة واحدة).
  static Directory? _cacheDir;
  static bool _cacheDirInitialized = false;

  /// لاحقة المتغير المناسب للإعدادات (مطابقة لـ [FontsExtension.getFontPath]).
  static String variantSuffix({required bool isDark, required bool tajweed}) =>
      tajweed ? (isDark ? 'd' : '') : (isDark ? 'nd' : 'n');

  static bool get _isTenRecitations {
    if (Get.isRegistered<WordInfoCtrl>()) {
      return WordInfoCtrl.instance.isTenRecitations;
    }
    return (GetStorage().read(_StorageConstants().isTenRecitations) ?? 0) == 1;
  }

  /// المتغيرات اللازمة لعرض صفحة بالإعدادات الحالية.
  static Set<String> _requiredVariants({bool? isDark}) {
    final dark = isDark ?? _lastIsDark;
    final tajweed = QuranCtrl.instance.state.isTajweedEnabled.value;
    final variants = <String>{variantSuffix(isDark: dark, tajweed: tajweed)};
    // كلمات الخلاف تُرسم بالخط الأحمر حين يكون التجويد معطّلًا مع القراءات العشر.
    if (!tajweed && _isTenRecitations) variants.add('nr');
    return variants;
  }

  /// هل متغير معيّن مسجّل للصفحة (1-based)؟
  static bool isVariantRegistered(int page, String suffix) =>
      _registered[page]?.contains(suffix) ?? false;

  /// هل الصفحة المحددة جاهزة للعرض بالإعدادات الحالية؟ (1-based)
  ///
  /// [isDark] إن مُرّر يُحفظ كآخر قيمة معروفة للوضع الداكن.
  static bool isPageReady(int page, {bool? isDark}) {
    if (isDark != null) _lastIsDark = isDark;
    final reg = _registered[page];
    if (reg == null) return false;
    return reg.containsAll(_requiredVariants());
  }

  /// يُستدعى من [FontsExtension.getFontPath] أثناء البناء: إن لم يكن المتغير
  /// المطلوب مسجّلًا بعد (تغيّر الوضع الداكن/التجويد)، يُجدول تسجيله بعد
  /// الإطار ثم يُعاد بناء الصفحة.
  static void noteVariantUsed(int page, String suffix, {bool? isDark}) {
    if (isDark != null) _lastIsDark = isDark;
    if (isVariantRegistered(page, suffix)) return;
    if (!_pendingVariantPages.add(page)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final cacheDir = await _ensureCacheDir();
        await Future.wait([
          _loadVariant(page, suffix, cacheDir),
          for (final v in _requiredVariants())
            if (v != suffix && !isVariantRegistered(page, v))
              _loadVariant(page, v, cacheDir),
        ]);
      } finally {
        _pendingVariantPages.remove(page);
      }
      if (isVariantRegistered(page, suffix)) _notifyPageFontsChanged(page);
    });
  }

  /// إعادة بناء صفحة المصحف بعد تسجيل متغير جديد لها. (النصوص المعروضة
  /// بالعائلة الجديدة يُعاد تخطيطها تلقائيًا عند تسجيل الخط عبر systemFonts.)
  static void _notifyPageFontsChanged(int page) {
    if (!Get.isRegistered<QuranCtrl>()) return;
    final ctrl = QuranCtrl.instance;
    if (ctrl.isClosed) return;
    ctrl.update(['qpc_page_${page - 1}']);
  }

  /// عدد الصفحات المحمّلة حتى الآن.
  static int get loadedCount => _registered.length;

  /// هل تم تحميل جميع الصفحات؟
  static bool get allLoaded => _registered.length >= _totalPages;

  /// اسم عائلة الخط للصفحة المحددة (page1 .. page604).
  static String getFontFamily(int pageIndex) => 'page${pageIndex + 1}';

  /// اسم عائلة الخط الداكن للصفحة المحددة (page1d .. page604d).
  static String getDarkFontFamily(int pageIndex) => 'page${pageIndex + 1}d';

  /// اسم عائلة الخط بدون تجويد فاتح (page1n .. page604n).
  static String getNoTajweedFontFamily(int pageIndex) =>
      'page${pageIndex + 1}n';

  /// اسم عائلة الخط بدون تجويد داكن (page1nd .. page604nd).
  static String getNoTajweedDarkFontFamily(int pageIndex) =>
      'page${pageIndex + 1}nd';

  /// اسم عائلة الخط الأحمر للخلاف (page1nr .. page604nr).
  static String getRedFontFamily(int pageIndex) => 'page${pageIndex + 1}nr';

  /// مسار الـ asset المضغوط للصفحة (1-based).
  static String _assetPath(int page) {
    final padded = page.toString().padLeft(3, '0');
    return 'packages/quran_library/assets/fonts/quran_fonts_qfc4/'
        'QCF4${padded}_COLOR-Regular.ttf.gz';
  }

  // ---------------------------------------------------------------------------
  // تهيئة مجلد الكاش
  // ---------------------------------------------------------------------------

  static Future<Directory?> _ensureCacheDir() async {
    if (_cacheDirInitialized) return _cacheDir;
    _cacheDirInitialized = true;
    if (kIsWeb) return null;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/quran_fonts_cache');
      // create(recursive) لا يفشل إن كان المجلد موجودًا — بلا existsSync.
      await dir.create(recursive: true);
      _cacheDir = dir;
    } catch (e) {
      log('QuranFontsService: failed to create cache dir: $e',
          name: 'QuranFontsService');
      _cacheDir = null;
    }
    return _cacheDir;
  }

  // ---------------------------------------------------------------------------
  // التحميل الكسول: تحميل صفحات قريبة فقط
  // ---------------------------------------------------------------------------

  /// تحميل الصفحات القريبة من [centerPage] (1-based) بنصف قطر [radius].
  ///
  /// مثال: `ensurePagesLoaded(100, radius: 10)` يحمّل الصفحات 90–110.
  /// يُسجَّل لكل صفحة المتغير اللازم للإعدادات الحالية فقط (انظر
  /// [isPageReady]). يتم تخطّي ما سُجّل مسبقًا. يُنتظر حتى انتهاء التحميل.
  static Future<void> ensurePagesLoaded(
    int centerPage, {
    int radius = 10,
    bool? isDark,
  }) async {
    if (isDark != null) _lastIsDark = isDark;
    final variants = _requiredVariants();
    final center = centerPage.clamp(1, _totalPages);
    final start = (centerPage - radius).clamp(1, _totalPages);
    final end = (centerPage + radius).clamp(1, _totalPages);

    // الصفحة المركزية أولاً ثم الأقرب فالأبعد.
    final order = <int>[center];
    for (int d = 1; d <= radius; d++) {
      if (center + d <= end) order.add(center + d);
      if (center - d >= start) order.add(center - d);
    }

    Directory? cacheDir;
    var cacheDirResolved = false;
    final futures = <Future<void>>[];
    for (final p in order) {
      for (final v in variants) {
        if (isVariantRegistered(p, v)) continue;
        if (!cacheDirResolved) {
          cacheDir = await _ensureCacheDir();
          cacheDirResolved = true;
        }
        futures.add(_loadVariant(p, v, cacheDir));
      }
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  /// تحميل بقية الصفحات في الخلفية بترتيب يبدأ من [startNearPage].
  ///
  /// تُحدّث [progress] (0.0–1.0) و[ready] عند الانتهاء الكامل.
  /// لا تُنتظر — تعمل بشكل غير متزامن.
  static Future<void> loadRemainingInBackground({
    required int startNearPage,
    required RxDouble progress,
    required RxBool ready,
  }) {
    if (allLoaded) {
      progress.value = 1.0;
      ready.value = true;
      return Future.value();
    }
    // منع التكرار
    _backgroundLoadFuture ??= _doLoadRemaining(
      startNearPage: startNearPage,
      progress: progress,
      ready: ready,
    );
    return _backgroundLoadFuture!;
  }

  static Future<void> _doLoadRemaining({
    required int startNearPage,
    required RxDouble progress,
    required RxBool ready,
  }) async {
    final cacheDir = await _ensureCacheDir();
    final loadOrder = _buildLoadOrder(startNearPage);

    for (final page in loadOrder) {
      for (final v in _requiredVariants()) {
        if (isVariantRegistered(page, v)) continue;
        await _loadVariant(page, v, cacheDir);
      }
      progress.value = _registered.length / _totalPages;
    }

    progress.value = 1.0;
    ready.value = true;
  }

  /// بناء ترتيب التحميل: يبدأ من [startPage] ويتوسع للخارج.
  ///
  /// مثلاً لو startPage=100: 100، 101، 99، 102، 98، 103، 97 ...
  static List<int> _buildLoadOrder(int startPage) {
    final order = <int>[];
    final start = startPage.clamp(1, _totalPages);
    order.add(start);

    for (int delta = 1; delta < _totalPages; delta++) {
      final after = start + delta;
      final before = start - delta;
      if (after <= _totalPages) order.add(after);
      if (before >= 1) order.add(before);
    }

    return order;
  }

  // ---------------------------------------------------------------------------
  // تسجيل متغير واحد لصفحة واحدة
  // ---------------------------------------------------------------------------

  /// تسجيل متغير واحد [suffix] للصفحة [page] (1-based).
  ///
  /// - `page{N}` — فاتح مع تجويد
  /// - `page{N}d` — داكن مع تجويد (CPAL: أسود→أبيض)
  /// - `page{N}n` — فاتح بدون تجويد (CPAL: كل الألوان→أسود)
  /// - `page{N}nd` — داكن بدون تجويد (CPAL: كل الألوان→أبيض)
  /// - `page{N}nr` — أحمر للخلاف (CPAL: كل الألوان→أحمر)
  static Future<void> _loadVariant(
      int page, String suffix, Directory? cacheDir) {
    final key = '$page:$suffix';
    return _variantLoadFutures.putIfAbsent(key, () async {
      try {
        final base = await _baseBytes(page, cacheDir);
        // المتغيرات تعدّل CPAL في مكانه، فتعمل على نسخة؛ الأصل يبقى في الكاش
        // (loadFontFromList ينسخ البايتات إلى المحرك ولا يعدّلها).
        final Uint8List bytes = switch (suffix) {
          'd' => _modifyCpalBaseColor(
              Uint8List.fromList(base), const Color(0xFFFFFFFF)),
          'n' => _modifyCpalAllColors(
              Uint8List.fromList(base), const Color(0xFF000000)),
          'nd' => _modifyCpalAllColors(
              Uint8List.fromList(base), const Color(0xFFFFFFFF)),
          'nr' => _modifyCpalAllColors(
              Uint8List.fromList(base), const Color(0xFFFF0000)),
          _ => base,
        };
        await loadFontFromList(bytes, fontFamily: 'page$page$suffix');
        (_registered[page] ??= <String>{}).add(suffix);
      } catch (e, st) {
        log('QuranFontsService: failed to load font page$page$suffix: $e',
            name: 'QuranFontsService', stackTrace: st);
        // السماح بإعادة المحاولة لاحقًا (المستدعون يتحققون من الجاهزية قبل
        // التحديث، فلا حلقة إعادة بناء).
        _variantLoadFutures.remove(key);
      }
    });
  }

  /// بايتات الخط الأصلية (المفكوكة) للصفحة: من كاش الذاكرة، ثم كاش القرص،
  /// ثم فك ضغط الـ asset.
  static Future<Uint8List> _baseBytes(int page, Directory? cacheDir) {
    final cached = _baseBytesCache.remove(page);
    if (cached != null) {
      _baseBytesCache[page] = cached; // الأحدث استخدامًا في النهاية
      return Future.value(cached);
    }
    return _baseBytesFutures.putIfAbsent(page, () async {
      try {
        final bytes = await _readOrDecompress(page, cacheDir);
        _baseBytesCache[page] = bytes;
        while (_baseBytesCache.length > _maxBaseBytesCache) {
          _baseBytesCache.remove(_baseBytesCache.keys.first);
        }
        return bytes;
      } finally {
        _baseBytesFutures.remove(page);
      }
    });
  }

  static Future<Uint8List> _readOrDecompress(
      int page, Directory? cacheDir) async {
    if (cacheDir == null) return _decompressFromAsset(page);

    final cachedFile = File('${cacheDir.path}/page$page.ttf');
    // قراءة مباشرة بدل existsSync على عزلة الواجهة: الغياب يرمي استثناءً.
    try {
      final bytes = await cachedFile.readAsBytes();
      if (bytes.isNotEmpty) return bytes;
    } catch (_) {}

    final bytes = await _decompressFromAsset(page);
    // الكتابة لا تؤخر التسجيل؛ ملف مؤقت ثم إعادة تسمية كي لا يُقرأ ملف
    // مبتور إن أُغلق التطبيق أثناء الكتابة.
    final tmp = File('${cachedFile.path}.tmp');
    tmp
        .writeAsBytes(bytes, flush: true)
        .then((_) => tmp.rename(cachedFile.path))
        .catchError((Object e) {
      log('QuranFontsService: cache write failed for page $page: $e',
          name: 'QuranFontsService');
      return cachedFile;
    });
    return bytes;
  }

  /// فك ضغط ملف `.ttf.gz` من الـ assets.
  ///
  /// zlib الأصلي (dart:io) على المنصات الأصلية — جزء من ميلي ثانية للصفحة،
  /// أرخص من إنشاء عزلة — و`archive` على الويب. بلا نسخة إضافية للبايتات.
  static Future<Uint8List> _decompressFromAsset(int page) async {
    final data = await rootBundle.load(_assetPath(page));
    return gunzipBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  // ---------------------------------------------------------------------------
  // تعديل جدول CPAL في ملف TTF/OTF
  // ---------------------------------------------------------------------------

  /// يبحث عن جدول `CPAL` في بيانات الخط ويستبدل اللون الأسود الأساسي
  /// (الطبقة الأساسية لنص القرآن) بـ [newBaseColor].
  ///
  /// ألوان التجويد (أحمر، أخضر، أزرق، إلخ) تبقى كما هي تماماً.
  /// إذا لم يُعثر على جدول CPAL، تُرجع البيانات بدون تعديل.
  static Uint8List _modifyCpalBaseColor(
      Uint8List fontBytes, Color newBaseColor) {
    final bd = ByteData.view(
        fontBytes.buffer, fontBytes.offsetInBytes, fontBytes.lengthInBytes);

    if (fontBytes.length < 12) return fontBytes;
    final numTables = bd.getUint16(4);

    int? cpalOffset;
    int? cpalLength;
    const cpalTag = 0x4350414C; // 'CPAL' in ASCII
    for (int t = 0; t < numTables; t++) {
      final recordOffset = 12 + t * 16;
      if (recordOffset + 16 > fontBytes.length) break;
      final tag = bd.getUint32(recordOffset);
      if (tag == cpalTag) {
        cpalOffset = bd.getUint32(recordOffset + 8);
        cpalLength = bd.getUint32(recordOffset + 12);
        break;
      }
    }

    if (cpalOffset == null || cpalLength == null) return fontBytes;
    if (cpalOffset + cpalLength > fontBytes.length) return fontBytes;

    if (cpalOffset + 12 > fontBytes.length) return fontBytes;
    final numColorRecords = bd.getUint16(cpalOffset + 6);
    final colorRecordsArrayOffset = bd.getUint32(cpalOffset + 8);

    final absColorRecordsOffset = cpalOffset + colorRecordsArrayOffset;

    final newR = (newBaseColor.r * 255).round();
    final newG = (newBaseColor.g * 255).round();
    final newB = (newBaseColor.b * 255).round();
    final newA = (newBaseColor.a * 255).round();

    for (int c = 0; c < numColorRecords; c++) {
      final colorOffset = absColorRecordsOffset + c * 4;
      if (colorOffset + 4 > fontBytes.length) break;

      final b = fontBytes[colorOffset];
      final g = fontBytes[colorOffset + 1];
      final r = fontBytes[colorOffset + 2];
      final a = fontBytes[colorOffset + 3];

      // اكتشاف اللون الأسود: RGB ≤ 30 و Alpha ≥ 200
      if (r <= 30 && g <= 30 && b <= 30 && a >= 200) {
        fontBytes[colorOffset] = newB;
        fontBytes[colorOffset + 1] = newG;
        fontBytes[colorOffset + 2] = newR;
        fontBytes[colorOffset + 3] = newA;
      }
    }

    return fontBytes;
  }

  /// يستبدل **جميع** ألوان CPAL بلون واحد موحّد.
  ///
  /// يُستخدم لإنشاء نسخة "بدون تجويد" حيث يُرسم كل شيء بلون واحد.
  static Uint8List _modifyCpalAllColors(Uint8List fontBytes, Color color) {
    final bd = ByteData.view(
        fontBytes.buffer, fontBytes.offsetInBytes, fontBytes.lengthInBytes);

    if (fontBytes.length < 12) return fontBytes;
    final numTables = bd.getUint16(4);

    int? cpalOffset;
    int? cpalLength;
    const cpalTag = 0x4350414C;
    for (int t = 0; t < numTables; t++) {
      final recordOffset = 12 + t * 16;
      if (recordOffset + 16 > fontBytes.length) break;
      final tag = bd.getUint32(recordOffset);
      if (tag == cpalTag) {
        cpalOffset = bd.getUint32(recordOffset + 8);
        cpalLength = bd.getUint32(recordOffset + 12);
        break;
      }
    }

    if (cpalOffset == null || cpalLength == null) return fontBytes;
    if (cpalOffset + cpalLength > fontBytes.length) return fontBytes;
    if (cpalOffset + 12 > fontBytes.length) return fontBytes;

    final numColorRecords = bd.getUint16(cpalOffset + 6);
    final colorRecordsArrayOffset = bd.getUint32(cpalOffset + 8);
    final absColorRecordsOffset = cpalOffset + colorRecordsArrayOffset;

    final newR = (color.r * 255).round();
    final newG = (color.g * 255).round();
    final newB = (color.b * 255).round();
    final newA = (color.a * 255).round();

    for (int c = 0; c < numColorRecords; c++) {
      final colorOffset = absColorRecordsOffset + c * 4;
      if (colorOffset + 4 > fontBytes.length) break;
      fontBytes[colorOffset] = newB;
      fontBytes[colorOffset + 1] = newG;
      fontBytes[colorOffset + 2] = newR;
      fontBytes[colorOffset + 3] = newA;
    }

    return fontBytes;
  }

  /// حذف كاش الخطوط من القرص.
  static Future<void> clearCache() async {
    if (kIsWeb) return;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/quran_fonts_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      log('QuranFontsService: clearCache failed: $e',
          name: 'QuranFontsService');
    }
    _registered.clear();
    _variantLoadFutures.clear();
    _baseBytesFutures.clear();
    _baseBytesCache.clear();
    _backgroundLoadFuture = null;
    _cacheDir = null;
    _cacheDirInitialized = false;
  }
}
