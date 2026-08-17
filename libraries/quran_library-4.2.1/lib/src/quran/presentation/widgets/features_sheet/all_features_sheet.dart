part of '/quran.dart';

/// One entry in the "all features" list sheet — see [_AllFeaturesListSheet].
class _FeatureListItem {
  const _FeatureListItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// A list of every Quran-reading feature (index, search, bookmarks, font
/// size, tajweed info, audio, auto-scroll, repeat), opened from the top
/// bar's menu icon. Tapping an item closes this sheet and opens that
/// feature in its own bottom sheet — see
/// `_QuranTopBar._showAllFeaturesBottomSheet`, which builds the [items].
class _AllFeaturesListSheet extends StatelessWidget {
  const _AllFeaturesListSheet({
    required this.textColor,
    required this.accentColor,
    required this.handleColor,
    required this.items,
  });

  final Color textColor;
  final Color accentColor;
  final Color? handleColor;
  final List<_FeatureListItem> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: handleColor ?? textColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ...items.map(
              (item) => ListTile(
                leading: Icon(item.icon, color: accentColor),
                title: Text(
                  item.label,
                  style: QuranLibrary().cairoStyle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
                trailing:
                    Icon(Icons.chevron_left, color: textColor.withValues(alpha: 0.4)),
                onTap: item.onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic single-feature bottom-sheet wrapper: a title header with a close
/// button above the feature's own content. When [expand] is true the sheet
/// is given a fixed, near-full height (for list-like content such as the
/// index/search/bookmarks tabs); otherwise it sizes to its content.
class _FeatureDetailSheet extends StatelessWidget {
  const _FeatureDetailSheet({
    required this.title,
    required this.textColor,
    required this.child,
    this.expand = false,
  });

  final String title;
  final Color textColor;
  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: QuranLibrary().cairoStyle.copyWith(
                fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: textColor, size: 20),
        ),
      ],
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: expand
            ? SizedBox(
                height: UiHelper.currentOrientation(
                    MediaQuery.of(context).size.height * 0.8,
                    MediaQuery.of(context).size.height * .9,
                    context),
                child: Column(
                  children: [
                    header,
                    const SizedBox(height: 4),
                    Expanded(child: child),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  header,
                  const SizedBox(height: 4),
                  child,
                ],
              ),
      ),
    );
  }
}

/// Font-size (page zoom) slider — mirrors the pinch-to-zoom `scaleFactor`.
class _FontSizeFeatureContent extends StatelessWidget {
  const _FontSizeFeatureContent({
    required this.accentColor,
  });

  final Color accentColor;

  static const double _minScale = 1.0;
  static const double _maxScale = 4.0;

  @override
  Widget build(BuildContext context) {
    final quranCtrl = QuranCtrl.instance;

    void setScale(double value) {
      quranCtrl.state.scaleFactor.value = value.clamp(_minScale, _maxScale);
      quranCtrl.state.baseScaleFactor.value = quranCtrl.state.scaleFactor.value;
      quranCtrl.update(['_pageViewBuild']);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: accentColor),
                  onPressed: () =>
                      setScale(quranCtrl.state.scaleFactor.value - 0.2),
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
                  icon: Icon(Icons.add_circle_outline, color: accentColor),
                  onPressed: () =>
                      setScale(quranCtrl.state.scaleFactor.value + 0.2),
                ),
              ],
            ),
            TextButton(
              onPressed: () => setScale(1.0),
              child: Text('إعادة الضبط', style: TextStyle(color: accentColor)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action tile — tapping stops any playing audio and opens [SurahAudioScreen].
class _AudioFeatureContent extends StatelessWidget {
  const _AudioFeatureContent({
    required this.textColor,
    required this.accentColor,
    required this.onTap,
  });

  final Color textColor;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.headphones, size: 48, color: accentColor),
              const SizedBox(height: 12),
              Text('فتح الاستماع للسور',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Toggle tile — tapping starts/stops [AutoScrollCtrl] from the current page.
class _AutoScrollFeatureContent extends StatelessWidget {
  const _AutoScrollFeatureContent({
    required this.textColor,
    required this.accentColor,
  });

  final Color textColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        final ctrl = AutoScrollCtrl.instance;
        final isActive = ctrl.state.isActive.value;
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isActive) {
              ctrl.stopAutoScroll();
            } else {
              final currentPage =
                  QuranCtrl.instance.state.currentPageNumber.value;
              ctrl.startAutoScroll(currentPage);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: 48,
                    color: accentColor),
                const SizedBox(height: 12),
                Text(
                    isActive
                        ? 'إيقاف التمرير التلقائي'
                        : 'تشغيل التمرير التلقائي',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      }),
    );
  }
}
