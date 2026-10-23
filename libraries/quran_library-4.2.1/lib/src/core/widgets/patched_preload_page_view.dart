part of '/quran.dart';

/// نسخة مُعدّلة من [PreloadPageView] تدعم [padEnds].
///
/// الحزمة الأصلية (preload_page_view 0.2.0) لا تمرر `padEnds` إلى
/// [SliverFillViewport]، فالقيمة الافتراضية `true` تُسبب هامشاً يجعل
/// `viewportFraction: 0.5` يعرض 1.5 صفحة بدل 2.
///
/// عند `padEnds: false`، تُعرض الصفحات بدون هامش إضافي.
class PatchedPreloadPageView extends StatefulWidget {
  PatchedPreloadPageView.builder({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    PreloadPageController? controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    this.preloadPagesCount = 1,
    this.padEnds = true,
  })  : controller = controller ?? PreloadPageController(),
        childrenDelegate =
            SliverChildBuilderDelegate(itemBuilder, childCount: itemCount);

  final Axis scrollDirection;
  final bool reverse;
  final PreloadPageController controller;
  final ScrollPhysics? physics;
  final bool pageSnapping;
  final ValueChanged<int>? onPageChanged;
  final SliverChildDelegate childrenDelegate;
  final int preloadPagesCount;

  /// عند false، لا يُضاف هامش قبل أول عنصر وبعد آخر عنصر.
  final bool padEnds;

  /// هل يمرّر أي [PatchedPreloadPageView] الآن (سحب أو حركة أو ارتداد)؟
  static bool get isAnyScrolling =>
      _PatchedPreloadPageViewState._scrolling.isNotEmpty;

  @override
  State<PatchedPreloadPageView> createState() => _PatchedPreloadPageViewState();
}

class _PatchedPreloadPageViewState extends State<PatchedPreloadPageView> {
  int _lastReportedPage = 0;

  /// نُسخ هذا الـ PageView التي تمرّر الآن (سحب أو حركة/ارتداد).
  ///
  /// [onPageChanged] يُطلق أثناء السحب (لإبقاء مؤشر الصفحة سريع الاستجابة)،
  /// أما العمل الثقيل (الحفظ وتحميل الخطوط وتحضير الكتل) فينتظر توقف التمرير
  /// عبر [PatchedPreloadPageView.isAnyScrolling].
  static final Set<_PatchedPreloadPageViewState> _scrolling = {};

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.controller.initialPage;
  }

  @override
  void dispose() {
    _scrolling.remove(this);
    super.dispose();
  }

  AxisDirection _getDirection(BuildContext context) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection =
            textDirectionToAxisDirection(textDirection);
        return widget.reverse
            ? flipAxisDirection(axisDirection)
            : axisDirection;
      case Axis.vertical:
        return widget.reverse ? AxisDirection.up : AxisDirection.down;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics? physics = widget.pageSnapping
        ? const PageScrollPhysics().applyTo(widget.physics)
        : widget.physics;

    final int preload = widget.preloadPagesCount;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.depth == 0) {
          if (notification is ScrollStartNotification) {
            _scrolling.add(this);
          } else if (notification is ScrollEndNotification) {
            _scrolling.remove(this);
          }
        }
        if (notification.depth == 0 &&
            widget.onPageChanged != null &&
            notification is ScrollUpdateNotification) {
          // نستخدم controller.page مباشرة بدل PageMetrics لتجنب
          // تعارض الأسماء بين Flutter و preload_page_view
          final int currentPage =
              widget.controller.page?.round() ?? _lastReportedPage;
          if (currentPage != _lastReportedPage) {
            _lastReportedPage = currentPage;
            widget.onPageChanged!(currentPage);
          }
        }
        return false;
      },
      child: Scrollable(
        axisDirection: axisDirection,
        controller: widget.controller,
        physics: physics,
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return Viewport(
            cacheExtent: preload < 1
                ? 0
                : (preload == 1
                    ? 1
                    : widget.scrollDirection == Axis.horizontal
                        ? MediaQuery.of(context).size.width * preload - 1
                        : MediaQuery.of(context).size.height * preload - 1),
            axisDirection: axisDirection,
            offset: position,
            slivers: <Widget>[
              SliverFillViewport(
                viewportFraction: widget.controller.viewportFraction,
                padEnds: widget.padEnds,
                delegate: widget.childrenDelegate,
              ),
            ],
          );
        },
      ),
    );
  }
}
