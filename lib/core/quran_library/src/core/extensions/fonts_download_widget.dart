part of 'package:azkark/core/quran_library/quran.dart';

/// Extension on `QuranCtrl` to provide additional functionality related to fonts download widget.
///
/// This extension adds methods and properties to the `QuranCtrl` class that are
/// specifically related to handling the fonts download widget in the application.
extension FontsDownloadWidgetExtension on QuranCtrl {
  /// A widget that displays the fonts download option.
  ///
  /// This widget provides a UI element for downloading fonts.
  ///
  /// [context] is the BuildContext in which the widget is built.
  ///
  /// Returns a Widget that represents the fonts download option.
  Widget fontsDownloadWidget(BuildContext context,
      {DownloadFontsDialogStyle? downloadFontsDialogStyle,
      String? languageCode,
      bool isDark = false,
      bool? isFontsLocal = false}) {
    final quranCtrl = QuranCtrl.instance;

    List<String> titleList = [
      downloadFontsDialogStyle?.defaultFontText ?? 'الخط الأساسي',
      downloadFontsDialogStyle?.downloadedFontsText ?? 'خط المصحف',
    ];
    // List<String> tajweedList = [
    //   downloadFontsDialogStyle?.withTajweedText ?? 'مع التجويد',
    //   downloadFontsDialogStyle?.withoutTajweedText ?? 'بدون تجويد',
    // ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            downloadFontsDialogStyle?.title ?? 'الخطوط',
            style: downloadFontsDialogStyle?.titleStyle ??
                TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'kufi',
                  color: downloadFontsDialogStyle?.titleColor ??
                      (isDark ? Colors.white : Colors.black),

                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          context.horizontalDivider(
            width: MediaQuery.sizeOf(context).width * .5,
            color: downloadFontsDialogStyle?.dividerColor ?? Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8.0),
          Text(
            downloadFontsDialogStyle?.notes ??
                'لجعل مظهر المصحف مشابه لمصحف المدينة يمكنك تحميل خطوط المصحف',
            style: downloadFontsDialogStyle?.notesStyle ??
                TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'naskh',
                    color: downloadFontsDialogStyle?.notesColor ??
                        (isDark ? Colors.white : Colors.black),),
          ),
          const SizedBox(
            height: 100,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              titleList.length,
              (i) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: downloadFontsDialogStyle
                                ?.downloadButtonBackgroundColor !=
                            null
                        ? downloadFontsDialogStyle!
                            .downloadButtonBackgroundColor!
                            .withValues(alpha: .2)
                        : isDark
                            ? Theme.of(context).primaryColor.withValues(alpha: .4)
                            : Theme.of(context).primaryColor.withValues(alpha: .2),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  color: quranCtrl.state.fontsSelected.value == i
                      ? downloadFontsDialogStyle?.linearProgressColor != null
                          ? downloadFontsDialogStyle?.linearProgressColor!
                              .withValues(alpha: .05)
                          : Theme.of(context).primaryColor.withValues(alpha: .05)
                      : null,
                  child: CheckboxListTile(
                    value: (quranCtrl.state.fontsSelected.value == i)
                        ? true
                        : false,
                    activeColor:
                        downloadFontsDialogStyle?.linearProgressColor ??
                            Theme.of(context).primaryColor,
                    secondary: i == 0
                        ? const SizedBox.shrink()
                        : isFontsLocal!
                            ? const SizedBox.shrink()
                            : Obx(() => quranCtrl
                                    .state.isPreparingDownload.value
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color: downloadFontsDialogStyle
                                              ?.linearProgressColor ??
                                          Theme.of(context).primaryColor,
                                    ),
                                  )
                                : IconButton(
                                    onPressed: () async {
                                      quranCtrl.state.isDownloadedV2Fonts.value
                                          ? await quranCtrl.deleteFonts()
                                          : quranCtrl.state.isDownloadingFonts
                                                      .value ||
                                                  quranCtrl.state
                                                      .isPreparingDownload.value
                                              ? null
                                              : await quranCtrl
                                                  .downloadAllFontsZipFile(i);
                                      log('fontIndex: $i');
                                    },
                                    icon:
                                        downloadFontsDialogStyle?.iconWidget ??
                                            Icon(
                                              quranCtrl.state
                                                      .isDownloadedV2Fonts.value
                                                  ? Icons.delete_forever
                                                  : Icons.downloading_outlined,
                                              color: downloadFontsDialogStyle
                                                      ?.iconColor ??
                                                  Theme.of(context).primaryColor,
                                              size: downloadFontsDialogStyle
                                                  ?.iconSize,
                                            ),
                                  )),
                    title: Text(
                      titleList[i],
                      style: downloadFontsDialogStyle?.fontNameStyle ??
                          TextStyle(
                            fontSize: 16,
                            fontFamily: 'naskh',
                            color: downloadFontsDialogStyle?.titleColor ??
                                (isDark ? Colors.white : Colors.black),

                          ),
                    ),
                    onChanged: isFontsLocal! ||
                            quranCtrl.state.isDownloadedV2Fonts.value
                        ? (_) {
                            quranCtrl.state.fontsSelected.value = i;
                            GetStorage()
                                .write(_StorageConstants().fontsSelected, i);
                            log('fontsSelected: $i');
                            Get.forceAppUpdate();
                          }
                        : null,
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () => quranCtrl.state.isDownloadingFonts.value
                ? Text(
                    '${downloadFontsDialogStyle?.downloadingText ?? 'جاري التحميل'} ${quranCtrl.state.fontsDownloadProgress.value.toStringAsFixed(1)}%'
                        .convertNumbersAccordingToLang(
                            languageCode: languageCode ?? 'ar'),
                    style: downloadFontsDialogStyle?.downloadingStyle ??
                        TextStyle(
                          color: downloadFontsDialogStyle?.notesColor ??
                              (isDark ? Colors.white : Colors.black),
                          fontSize: 16,
                          fontFamily: 'naskh',

                        ),
                  )
                : const SizedBox.shrink(),
          ),
          Obx(
            () => quranCtrl.state.isDownloadedV2Fonts.value
                ? const SizedBox.shrink()
                : LinearProgressIndicator(
                    backgroundColor: downloadFontsDialogStyle
                            ?.linearProgressBackgroundColor ??
                        Colors.blue.shade100,
                    value: (quranCtrl.state.fontsDownloadProgress.value / 100),
                    color: downloadFontsDialogStyle?.linearProgressColor ??
                        Theme.of(context).primaryColor,
                  ),
          ),
        ],
      ),
    );
  }
}
