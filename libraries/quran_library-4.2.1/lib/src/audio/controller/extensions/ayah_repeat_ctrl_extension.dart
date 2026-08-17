// ignore_for_file: use_build_context_synchronously

part of '../../audio.dart';

/// محرك تشغيل تكرار نطاق آيات (من آية بداية إلى آية نهاية) مع دعم:
/// - تكرار كل آية على حدة عددًا معينًا من المرات قبل الانتقال للتالية.
/// - مهلة انتظار بين كل تكرار وآخر.
/// - تكرار النطاق بأكمله (الفقرة) عددًا معينًا من المرات بعد اكتمال الدورة الأولى.
///
/// Engine for playing back an ayah range (start -> end) with:
/// - Per-ayah repeat count before moving to the next ayah.
/// - A wait duration between repeats.
/// - Whole-section (range) repeat count once the range finishes.
extension AyahRepeatCtrlExtension on AudioCtrl {
  /// هل يوجد تكرار نطاق آيات نشط الآن.
  bool get isAyahRangeRepeatActive => state.isAyahRangeRepeatActive.value;

  /// يبني قائمة مرتّبة بأرقام الآيات الفريدة (ayahUQNumber) بدءًا من
  /// (startSurah, startAya) وحتى (endSurah, endAya) شاملةً الطرفين،
  /// مع اجتياز حدود السور بشكل صحيح حسب ترتيب المصحف.
  List<int> buildAyahRangeUQNumbers({
    required int startSurah,
    required int startAya,
    required int endSurah,
    required int endAya,
  }) {
    // طبّع الحدود بحيث تكون البداية دائمًا قبل أو تساوي النهاية حسب ترتيب المصحف
    int sSurah = startSurah, sAya = startAya, eSurah = endSurah, eAya = endAya;
    final startsAfterEnd = sSurah > eSurah || (sSurah == eSurah && sAya > eAya);
    if (startsAfterEnd) {
      final tmpSurah = sSurah, tmpAya = sAya;
      sSurah = eSurah;
      sAya = eAya;
      eSurah = tmpSurah;
      eAya = tmpAya;
    }

    final List<int> result = [];
    for (final surah in QuranCtrl.instance.surahs) {
      if (surah.surahNumber < sSurah || surah.surahNumber > eSurah) continue;
      for (final ayah in surah.ayahs) {
        if (surah.surahNumber == sSurah && ayah.ayahNumber < sAya) continue;
        if (surah.surahNumber == eSurah && ayah.ayahNumber > eAya) continue;
        result.add(ayah.ayahUQNumber);
      }
    }
    return result;
  }

  /// إلغاء تكرار نطاق الآيات الجاري (إن وجد) وتنظيف كل المؤقّتات/الاشتراكات
  /// المرتبطة به دون تسريب أي منها.
  Future<void> cancelAyahRangeRepeat() async {
    state.isAyahRangeRepeatActive.value = false;

    final cancelCompleter = state.ayahRangeRepeatCancelCompleter;
    if (cancelCompleter != null && !cancelCompleter.isCompleted) {
      cancelCompleter.complete();
    }
    state.ayahRangeRepeatCancelCompleter = null;

    state.ayahRangeWaitTimer?.cancel();
    state.ayahRangeWaitTimer = null;

    await pausePlayer();
  }

  /// يبدأ تشغيل تكرار نطاق الآيات من (startSurah, startAya) إلى
  /// (endSurah, endAya) وفق إعدادات التكرار المُمرَّرة.
  ///
  /// [repeatPerAyah]: إجمالي عدد مرات تشغيل الآية الواحدة (0 أو 1 = بدون
  /// تكرار، أي تُشغَّل مرة واحدة فقط؛ 2 تعني مرتين إجمالًا... وهكذا).
  ///
  /// [waitSeconds]: مهلة الانتظار بالثواني بين كل تكرار وآخر لنفس الآية
  /// (0 = بدون انتظار).
  ///
  /// [repeatSection]: إجمالي عدد مرات تشغيل النطاق (الفقرة) كاملًا (0 أو 1 =
  /// بدون تكرار، أي يُشغَّل النطاق مرة واحدة فقط؛ 2 تعني مرتين إجمالًا...
  /// وهكذا).
  Future<void> startAyahRangeRepeat(
    BuildContext context, {
    required int startSurah,
    required int startAya,
    required int endSurah,
    required int endAya,
    int repeatPerAyah = 0,
    int waitSeconds = 0,
    int repeatSection = 0,
    AyahAudioStyle? ayahAudioStyle,
    bool? isDarkMode,
  }) async {
    if (!await canPlayAudio()) return;

    // أوقف أي تكرار سابق نظيفًا قبل بدء تكرار جديد
    await cancelAyahRangeRepeat();

    final ayahsUQ = buildAyahRangeUQNumbers(
      startSurah: startSurah,
      startAya: startAya,
      endSurah: endSurah,
      endAya: endAya,
    );
    if (ayahsUQ.isEmpty) return;

    state.isPlayingSurahsMode = false;
    disableSurahAutoNextListener();
    disableSurahPositionSaving();

    state.isAyahRangeRepeatActive.value = true;
    final cancelCompleter = Completer<void>();
    state.ayahRangeRepeatCancelCompleter = cancelCompleter;

    final bool isDark =
        isDarkMode ?? MediaQuery.of(context).platformBrightness == Brightness.dark;
    final style =
        ayahAudioStyle ?? AyahAudioStyle.defaults(isDark: isDark, context: context);

    bool cancelled() =>
        !state.isAyahRangeRepeatActive.value || cancelCompleter.isCompleted;

    try {
      // repeatSection/repeatPerAyah are the desired TOTAL play counts, not
      // extra repeats on top of a first play. 0 (or less) still means
      // "no repeat", i.e. exactly one run.
      final int totalSectionRuns = repeatSection <= 0 ? 1 : repeatSection;
      for (int section = 0; section < totalSectionRuns; section++) {
        if (cancelled()) return;
        for (final ayahUQ in ayahsUQ) {
          if (cancelled()) return;
          final int totalAyahRuns = repeatPerAyah <= 0 ? 1 : repeatPerAyah;
          for (int run = 0; run < totalAyahRuns; run++) {
            if (cancelled()) return;

            state.currentAyahUniqueNumber.value = ayahUQ;
            QuranCtrl.instance
                .toggleAyahSelection(ayahUQ, forceAddition: true);

            await _playSingleAyahFile(context, ayahUQ, ayahAudioStyle: style);
            if (cancelled()) return;

            // انتظر حتى ينتهي تشغيل الآية الحالية أو يُطلب الإلغاء
            final completedFuture = state.audioPlayer.playerStateStream
                .firstWhere(
                    (s) => s.processingState == ProcessingState.completed);
            await Future.any([completedFuture, cancelCompleter.future]);
            if (cancelled()) return;

            // مهلة انتظار اختيارية بين كل تكرار وآخر
            if (waitSeconds > 0) {
              final waitCompleter = Completer<void>();
              final timer = Timer(Duration(seconds: waitSeconds), () {
                if (!waitCompleter.isCompleted) waitCompleter.complete();
              });
              state.ayahRangeWaitTimer = timer;
              await Future.any([waitCompleter.future, cancelCompleter.future]);
              timer.cancel();
              state.ayahRangeWaitTimer = null;
              if (cancelled()) return;
            }
          }
        }
      }
    } finally {
      // إن انتهى التشغيل بشكل طبيعي (وليس عبر الإلغاء) أعد ضبط الحالة
      if (state.isAyahRangeRepeatActive.value) {
        state.isAyahRangeRepeatActive.value = false;
      }
      if (identical(state.ayahRangeRepeatCancelCompleter, cancelCompleter)) {
        state.ayahRangeRepeatCancelCompleter = null;
      }
    }
  }
}
