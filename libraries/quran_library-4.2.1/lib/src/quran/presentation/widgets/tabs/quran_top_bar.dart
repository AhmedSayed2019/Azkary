part of '/quran.dart';

class _QuranTopBar extends StatelessWidget {
  final String languageCode;
  final bool isDark;
  final SurahAudioStyle? style;
  final bool? isFontsLocal;
  final DownloadFontsDialogStyle? downloadFontsDialogStyle;
  final Color? backgroundColor;
  final bool? isSingleSurah;
  final bool? isPagesView;

  const _QuranTopBar(
    this.languageCode,
    this.isDark, {
    this.style,
    this.isFontsLocal,
    this.downloadFontsDialogStyle,
    this.backgroundColor,
    this.isSingleSurah = false,
    this.isPagesView = false,
  });

  @override
  Widget build(BuildContext context) {
    // Centralized theming (read from theme or fallback to defaults)
    final QuranTopBarStyle defaults = QuranTopBarTheme.of(context)?.style ??
        QuranTopBarStyle.defaults(isDark: isDark, context: context);

    final TajweedMenuStyle tajweedStyle = TajweedMenuTheme.of(context)?.style ??
        TajweedMenuStyle.defaults(isDark: isDark, context: context);
    final Color bgColor = backgroundColor ??
        (defaults.backgroundColor ?? AppColors.getBackgroundColor(isDark));

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: defaults.height ?? 55,
        padding:
            defaults.padding ?? const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(defaults.borderRadius ?? 12),
          boxShadow: [
            BoxShadow(
              color:
                  (defaults.shadowColor ?? Colors.black.withValues(alpha: .2)),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 5), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            if (defaults.showBackButton ?? false)
              IconButton(
                icon: SvgPicture.asset(
                    defaults.backIconPath ?? AssetsPath.assets.backArrow,
                    height: defaults.iconSize,
                    colorFilter: ColorFilter.mode(
                        defaults.iconColor ??
                            Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            if (defaults.showMenuButton ?? true)
              IconButton(
                icon: SvgPicture.asset(
                    defaults.menuIconPath ?? AssetsPath.assets.buttomSheet,
                    height: defaults.iconSize,
                    colorFilter: ColorFilter.mode(
                        defaults.iconColor ??
                            Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn)),
                onPressed: () {
                  QuranCtrl.instance.searchFocusNode.requestFocus();
                  _showMenuBottomSheet(context, defaults);
                },
              ),
            if ((defaults.showMenuButton ?? true) &&
                (QuranCtrl.instance.state.fontsSelected.value == 0))
              IconButton(
                icon: SvgPicture.asset(
                    defaults.tajweedIconPath ?? AssetsPath.assets.exclamation,
                    height: defaults.iconSize,
                    colorFilter: ColorFilter.mode(
                        defaults.iconColor ??
                            Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn)),
                onPressed: () {
                  _showDialog(context, tajweedStyle);
                },
              ),
            const Spacer(),
            if (defaults.customTopBarWidgets != null)
              ...defaults.customTopBarWidgets!,
            const Spacer(),
            Row(
              children: [
                if (defaults.showAutoScrollButton ?? true)
                  Obx(() {
                    final isAutoScrollActive =
                        AutoScrollCtrl.instance.state.isActive.value;
                    return QuranCtrl.instance.state.displayMode.value ==
                            QuranDisplayMode.defaultMode
                        ? IconButton(
                            icon: SvgPicture.asset(
                                defaults.autoScrollIconPath ??
                                    AssetsPath.assets.arrowDown,
                                height: defaults.iconSize,
                                colorFilter: ColorFilter.mode(
                                    isAutoScrollActive
                                        ? (defaults.iconColor ??
                                            Theme.of(context)
                                                .colorScheme
                                                .primary)
                                        : (defaults.iconColor ??
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary)
                                            .withValues(alpha: 0.5),
                                    BlendMode.srcIn)),
                            //   Icon(
                            //   Icons.speed,
                            //   size: defaults.iconSize ?? 22,
                            //   color: isAutoScrollActive
                            //       ? (defaults.accentColor ??
                            //           Theme.of(context).colorScheme.primary)
                            //       : (defaults.iconColor ??
                            //           Theme.of(context).colorScheme.primary),
                            // ),
                            onPressed: () {
                              final ctrl = AutoScrollCtrl.instance;
                              if (ctrl.state.isActive.value) {
                                ctrl.stopAutoScroll();
                              } else {
                                final currentPage = QuranCtrl
                                    .instance.state.currentPageNumber.value;
                                ctrl.startAutoScroll(currentPage);
                              }
                            },
                          )
                        : const SizedBox.shrink();
                  }),
                if (defaults.showAudioButton ?? true)
                  IconButton(
                    icon: SvgPicture.asset(
                        defaults.audioIconPath ?? AssetsPath.assets.surahsAudio,
                        height: defaults.iconSize,
                        colorFilter: ColorFilter.mode(
                            defaults.iconColor ??
                                Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn)),
                    onPressed: () async {
                      await AudioCtrl.instance.state.audioPlayer.stop();
                      QuranCtrl.instance.state.isShowMenu.value = false;
                      // await AudioCtrl.instance.lastAudioSource();
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahAudioScreen(
                              isDark: isDark,
                              style: style ??
                                  SurahAudioStyle.defaults(
                                      isDark: isDark, context: context),
                              languageCode: languageCode,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                if ((defaults.showFontsButton ?? true) && (!isSingleSurah!) ||
                    (isPagesView!))
                  FontsDownloadDialog(
                    downloadFontsDialogStyle: downloadFontsDialogStyle ??
                        DownloadFontsDialogStyle.defaults(isDark, context),
                    languageCode: languageCode,
                    isFontsLocal: isFontsLocal,
                    isDark: isDark,
                  ),
                IconButton(
                  icon: Icon(
                    Icons.format_size,
                    size: defaults.iconSize,
                    color:
                        defaults.iconColor ?? Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => _showSizeSideMenu(context, defaults),
                ),
                IconButton(
                  icon: Icon(
                    Icons.menu,
                    size: defaults.iconSize,
                    color:
                        defaults.iconColor ?? Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => _showAllFeaturesBottomSheet(
                      context, defaults, tajweedStyle),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, TajweedMenuStyle defaults) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: backgroundColor ??
            defaults.backgroundColor ??
            AppColors.getBackgroundColor(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaults.borderRadius ?? 12),
        ),
        child: TajweedMenuWidget(isDark: isDark, languageCode: languageCode),
      ),
    );
  }

  void _showMenuBottomSheet(BuildContext context, QuranTopBarStyle defaults) {
    // التقط الأنماط من الـ Theme قبل الدخول لحدود bottom sheet
    final indexTabStyle = IndexTabTheme.of(context)?.style ??
        IndexTabStyle.defaults(isDark: isDark, context: context);
    final searchTabStyle = SearchTabTheme.of(context)?.style ??
        SearchTabStyle.defaults(isDark: isDark, context: context);
    final bookmarksTabStyle = BookmarksTabTheme.of(context)?.style ??
        BookmarksTabStyle.defaults(isDark: isDark, context: context);

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor ??
          defaults.backgroundColor ??
          AppColors.getBackgroundColor(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(defaults.borderRadius ?? 20)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: UiHelper.currentOrientation(
            double.infinity, MediaQuery.sizeOf(context).width * 0.5, context),
      ),
      builder: (ctx) => _MenuBottomSheet(
        isDark: isDark,
        languageCode: languageCode,
        backgroundColor: backgroundColor,
        style: defaults,
        indexTabStyle: indexTabStyle,
        searchTabStyle: searchTabStyle,
        bookmarksTabStyle: bookmarksTabStyle,
        isSingleSurah: isSingleSurah!,
      ),
    );
  }

  /// Opens the consolidated "all features" list (index, search, bookmarks,
  /// font size, tajweed, audio, auto-scroll, repeat). Tapping an item closes
  /// this list and opens that single feature in its own bottom sheet.
  void _showAllFeaturesBottomSheet(
    BuildContext context,
    QuranTopBarStyle defaults,
    TajweedMenuStyle tajweedStyle,
  ) {
    final indexTabStyle = IndexTabTheme.of(context)?.style ??
        IndexTabStyle.defaults(isDark: isDark, context: context);
    final searchTabStyle = SearchTabTheme.of(context)?.style ??
        SearchTabStyle.defaults(isDark: isDark, context: context);
    final bookmarksTabStyle = BookmarksTabTheme.of(context)?.style ??
        BookmarksTabStyle.defaults(isDark: isDark, context: context);

    final Color textColor = defaults.textColor ?? AppColors.getTextColor(isDark);
    final Color accentColor =
        defaults.accentColor ?? Theme.of(context).colorScheme.primary;
    final Color bgColor = backgroundColor ??
        defaults.backgroundColor ??
        AppColors.getBackgroundColor(isDark);
    final double radius = defaults.borderRadius ?? 20;
    final bool showTajweed = QuranCtrl.instance.state.fontsSelected.value == 0;

    void openFeatureSheet({
      required String title,
      required Widget content,
      bool expand = false,
    }) {
      Navigator.of(context).pop(); // close the list sheet first
      showModalBottomSheet(
        context: context,
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        ),
        isScrollControlled: true,
        builder: (ctx) => _FeatureDetailSheet(
          title: title,
          textColor: textColor,
          expand: expand,
          child: content,
        ),
      );
    }

    final items = <_FeatureListItem>[
      if (!isSingleSurah!)
        _FeatureListItem(
          icon: Icons.list_alt,
          label: 'الفهرس',
          onTap: () => openFeatureSheet(
            title: 'الفهرس',
            expand: true,
            content: _IndexTab(
                isDark: isDark, languageCode: languageCode, style: indexTabStyle),
          ),
        ),
      _FeatureListItem(
        icon: Icons.search,
        label: 'البحث',
        onTap: () => openFeatureSheet(
          title: 'البحث',
          expand: true,
          content: _SearchTab(
              isDark: isDark, languageCode: languageCode, style: searchTabStyle),
        ),
      ),
      _FeatureListItem(
        icon: Icons.bookmark_outline,
        label: 'الفواصل',
        onTap: () => openFeatureSheet(
          title: 'الفواصل',
          expand: true,
          content: _BookmarksTab(
              isDark: isDark,
              languageCode: languageCode,
              style: bookmarksTabStyle),
        ),
      ),
      _FeatureListItem(
        icon: Icons.format_size,
        label: 'حجم الخط',
        onTap: () => openFeatureSheet(
          title: 'حجم الخط',
          content: _FontSizeFeatureContent(accentColor: accentColor),
        ),
      ),
      if (showTajweed)
        _FeatureListItem(
          icon: Icons.info_outline,
          label: 'التجويد',
          onTap: () => openFeatureSheet(
            title: 'التجويد',
            content: Center(
                child: TajweedMenuWidget(
                    languageCode: languageCode, isDark: isDark)),
          ),
        ),
      _FeatureListItem(
        icon: Icons.headphones,
        label: 'الاستماع',
        onTap: () => openFeatureSheet(
          title: 'الاستماع',
          content: _AudioFeatureContent(
            textColor: textColor,
            accentColor: accentColor,
            onTap: () async {
              await AudioCtrl.instance.state.audioPlayer.stop();
              QuranCtrl.instance.state.isShowMenu.value = false;
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SurahAudioScreen(
                      isDark: isDark,
                      style: style ??
                          SurahAudioStyle.defaults(isDark: isDark, context: context),
                      languageCode: languageCode,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
      _FeatureListItem(
        icon: Icons.speed,
        label: 'التمرير التلقائي',
        onTap: () => openFeatureSheet(
          title: 'التمرير التلقائي',
          content:
              _AutoScrollFeatureContent(textColor: textColor, accentColor: accentColor),
        ),
      ),
      _FeatureListItem(
        icon: Icons.repeat,
        label: 'التكرار',
        onTap: () {
          Navigator.of(context).pop();
          showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
            ),
            builder: (ctx) => AyahRepeatSheet(isDark: isDark),
          );
        },
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _AllFeaturesListSheet(
        textColor: textColor,
        accentColor: accentColor,
        handleColor: defaults.handleColor,
        items: items,
      ),
    );
  }

  void _showSizeSideMenu(BuildContext context, QuranTopBarStyle defaults) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, _, __) => _SizeSideMenu(
        isDark: isDark,
        isRtl: isRtl,
        backgroundColor: backgroundColor ??
            defaults.backgroundColor ??
            AppColors.getBackgroundColor(isDark),
        textColor: defaults.textColor ?? AppColors.getTextColor(isDark),
        accentColor: defaults.accentColor ?? Theme.of(context).colorScheme.primary,
      ),
      transitionBuilder: (dialogContext, animation, _, child) {
        final tween = Tween<Offset>(
          begin: Offset(isRtl ? 1 : -1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

/// A side panel (opened from the app bar's size icon) to control the
/// Quran page zoom/font size, mirroring the pinch-to-zoom `scaleFactor`.
class _SizeSideMenu extends StatelessWidget {
  const _SizeSideMenu({
    required this.isDark,
    required this.isRtl,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
  });

  final bool isDark;
  final bool isRtl;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;

  static const double _minScale = 1.0;
  static const double _maxScale = 4.0;

  @override
  Widget build(BuildContext context) {
    final quranCtrl = QuranCtrl.instance;
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth < 360 ? screenWidth * 0.85 : 320.0;

    void setScale(double value) {
      quranCtrl.state.scaleFactor.value = value.clamp(_minScale, _maxScale);
      quranCtrl.state.baseScaleFactor.value = quranCtrl.state.scaleFactor.value;
      quranCtrl.update(['_pageViewBuild']);
    }

    return Align(
      alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
      child: Material(
        color: backgroundColor,
        elevation: 8,
        borderRadius: BorderRadius.horizontal(
          left: isRtl ? const Radius.circular(20) : Radius.zero,
          right: isRtl ? Radius.zero : const Radius.circular(20),
        ),
        child: SafeArea(
          child: SizedBox(
            width: panelWidth,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'حجم الخط',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline,
                                  color: accentColor),
                              onPressed: () => setScale(
                                  quranCtrl.state.scaleFactor.value - 0.2),
                            ),
                            Expanded(
                              child: Slider(
                                value: quranCtrl.state.scaleFactor.value
                                    .clamp(_minScale, _maxScale),
                                min: _minScale,
                                max: _maxScale,
                                activeColor: accentColor,
                                onChanged: setScale,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline,
                                  color: accentColor),
                              onPressed: () => setScale(
                                  quranCtrl.state.scaleFactor.value + 0.2),
                            ),
                          ],
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () => setScale(1.0),
                            child: Text(
                              'إعادة الضبط',
                              style: TextStyle(color: accentColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// BottomSheet container with main TabBar
class _MenuBottomSheet extends StatelessWidget {
  final bool isDark;
  final String languageCode;
  final Color? backgroundColor;
  final QuranTopBarStyle style;
  final IndexTabStyle indexTabStyle;
  final SearchTabStyle searchTabStyle;
  final BookmarksTabStyle bookmarksTabStyle;
  final bool isSingleSurah;

  const _MenuBottomSheet({
    required this.isDark,
    required this.languageCode,
    this.backgroundColor,
    required this.style,
    required this.indexTabStyle,
    required this.searchTabStyle,
    required this.bookmarksTabStyle,
    this.isSingleSurah = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = style.textColor ?? AppColors.getTextColor(isDark);
    final Color accentColor =
        style.accentColor ?? Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: isSingleSurah ? 2 : 3,
      child: SafeArea(
        top: false,
        child: Container(
          height: UiHelper.currentOrientation(
              MediaQuery.of(context).size.height * 0.8,
              MediaQuery.of(context).size.height * .9,
              context),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Drag handle + header
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color:
                      (style.handleColor ?? textColor.withValues(alpha: 0.25)),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorPadding:
                      style.indicatorPadding ?? const EdgeInsets.all(4),
                  padding: EdgeInsets.zero,
                  labelColor: Colors.white,
                  unselectedLabelColor: textColor.withValues(alpha: 0.6),
                  indicatorColor: accentColor,
                  indicatorWeight: .5,
                  labelStyle: QuranLibrary().cairoStyle.copyWith(
                      fontSize: 15, fontWeight: FontWeight.w700, height: 1.3),
                  unselectedLabelStyle:
                      QuranLibrary().cairoStyle.copyWith(fontSize: 15),
                  tabs: [
                    if (!isSingleSurah)
                      Tab(text: style.tabIndexLabel ?? 'الفهرس'),
                    Tab(text: style.tabSearchLabel ?? 'البحث'),
                    Tab(text: style.tabBookmarksLabel ?? 'الفواصل'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: TabBarView(
                  children: [
                    if (!isSingleSurah)
                      _IndexTab(
                        isDark: isDark,
                        languageCode: languageCode,
                        style: indexTabStyle,
                      ),
                    _SearchTab(
                      isDark: isDark,
                      languageCode: languageCode,
                      style: searchTabStyle,
                    ),
                    _BookmarksTab(
                      isDark: isDark,
                      languageCode: languageCode,
                      style: bookmarksTabStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

