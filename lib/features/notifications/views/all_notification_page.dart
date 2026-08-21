// شاشة التنبيهات — أذونات + تذكيرات مجدولة.
//
// النسخة السابقة كانت أربع بطاقات متطابقة منسوخة يدويًا (١٠١٣ سطرًا) تقرأ
// `getValue("darkMode")` في كل سطر لون، وتُسجّل مهام WorkManager مباشرة من
// داخل `onChanged`. أُعيدت بناءً على [ReminderScheduler] و[AppPermissions]:
// المفتاح لا يُقلب إلا بعد التأكد من إذن الإشعارات وإتمام الجدولة فعليًا،
// والألوان من `AppColor` فتتبع الوضع الليلي تلقائيًا.

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/core/utils/permissions/app_permissions.dart';
import 'package:azkark/features/notifications/logic/reminder_scheduler.dart';
import 'package:azkark/features/notifications/logic/zikr_overlay_scheduler.dart';
import 'package:azkark/features/prayer/azan_scheduler.dart';
import 'package:azkark/widgets/islamic_header_background.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with WidgetsBindingObserver {
  List<AppPermissionState> _permissions = const [];
  int _pending = 0;
  bool _busy = false;
  bool _overlayOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // أذونات «المنبهات الدقيقة» و«البطارية» و«العرض فوق التطبيقات» تُمنح في
    // شاشة إعدادات خارجية، فالعودة للمقدمة هي إشارتنا الوحيدة لإعادة الفحص.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final permissions = await AppPermissions.audit();
    final pending = await ReminderScheduler.pendingCount();
    // المفتاح يعكس الواقع: مفعّل في التفضيلات *و* الإذن ممنوح فعلًا،
    // فسحب الإذن من إعدادات النظام يُطفئه بدل أن يبقى أخضر كاذبًا.
    final overlayOn = await ZikrOverlayScheduler.enabled() &&
        await ZikrOverlayScheduler.hasPermission();
    if (!mounted) return;
    setState(() {
      _permissions = permissions;
      _pending = pending;
      _overlayOn = overlayOn;
    });
  }

  List<AppPermissionState> get _missing =>
      _permissions.where((p) => p.needsAttention).toList(growable: false);

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
          message,
          style: const TextStyle().mediumStyle(fontSize: 13).colorWhite(),
        ),
        backgroundColor: error
            ? AppColor.errorColor.themeColor
            : AppColor.primaryColor.themeColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(kScreenPaddingNormal.w),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ));
  }

  /// تفعيل/تعطيل تذكير. لا نقلب المفتاح قبل إذن الإشعارات: بدونه تنجح
  /// الجدولة ولا يرى المستخدم شيئًا — وهو تمامًا ما كان يحدث سابقًا.
  Future<void> _toggleReminder(ReminderKind kind, bool value) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (value && !await AppPermissions.ensureNotifications()) {
        _toast('لن تصلك التنبيهات قبل السماح بالإشعارات', error: true);
        return;
      }
      await ReminderScheduler.setEnabled(kind, value);
      if (value && !await AppPermissions.isGranted(AppPermissionKind.exactAlarm)) {
        _toast('فُعِّل التذكير — فعّل «المنبهات الدقيقة» ليصل في وقته بالضبط');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
      await _refresh();
    }
  }

  Future<void> _setInterval(ReminderKind kind, int index) async {
    await ReminderScheduler.setIntervalIndex(kind, index);
    await _refresh();
  }

  Future<void> _sample(ReminderKind kind) async {
    if (!await AppPermissions.ensureNotifications()) {
      _toast('لن تصلك التنبيهات قبل السماح بالإشعارات', error: true);
      return;
    }
    final ok = await ReminderScheduler.showSample(kind);
    if (!ok) _toast('تعذّر عرض المثال', error: true);
  }

  /// إذن «العرض فوق التطبيقات» لا يُمنح بحوار عادي بل من شاشة إعدادات
  /// مستقلة، فنطلبه أولًا ولا نُفعّل المفتاح إن رجع المستخدم بلا منح.
  Future<void> _toggleOverlay(bool value) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (value && !await ZikrOverlayScheduler.hasPermission()) {
        final granted = await ZikrOverlayScheduler.requestPermission();
        if (!granted) {
          _toast('يحتاج الذكر العائم إذن «العرض فوق التطبيقات»', error: true);
          return;
        }
      }
      await ZikrOverlayScheduler.setEnabled(value);
      if (mounted) setState(() => _overlayOn = value);
    } finally {
      if (mounted) setState(() => _busy = false);
      await _refresh();
    }
  }

  Future<void> _toggleSally(bool value) async {
    if (value && !await AppPermissions.ensureNotifications()) {
      _toast('لن تصلك التنبيهات قبل السماح بالإشعارات', error: true);
      return;
    }
    await ReminderScheduler.setSallyEnabled(value);
    if (mounted) setState(() {});
  }

  Future<void> _setHour({required bool isStart}) async {
    final current = isStart
        ? ReminderScheduler.startHour
        : ReminderScheduler.endHour;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current, minute: 0),
      helpText: isStart ? 'بداية التذكير' : 'نهاية التذكير',
    );
    if (picked == null) return;
    await ReminderScheduler.setActiveWindow(
      start: isStart ? picked.hour : null,
      end: isStart ? null : picked.hour,
    );
    if (mounted) setState(() {});
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackgroundColor.themeColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              kScreenPaddingNormal.w,
              kScreenPaddingNormal.h,
              kScreenPaddingNormal.w,
              kScreenPaddingLarge.h,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_missing.isNotEmpty) ...[
                  _PermissionsPanel(
                    missing: _missing,
                    onFix: (kind) async {
                      await AppPermissions.request(kind);
                      // منح الإذن وحده لا يُجدول شيئًا — لا بد من إعادة
                      // تسليح ما فشلت جدولته قبل المنح. «المنبهات الدقيقة»
                      // تخص الأذان أيضًا، وإلا بقيت مواقيته داخل نافذة ساعة.
                      await ReminderScheduler.arm();
                      if (kind == AppPermissionKind.exactAlarm) {
                        await AzanScheduler.reschedule();
                      }
                      await _refresh();
                    },
                  ),
                  SizedBox(height: kScreenPaddingNormal.h),
                ],
                const _SectionLabel('التذكيرات'),
                SizedBox(height: kFormPaddingAllNormal.h),
                _ReminderCard(
                  icon: Icons.self_improvement_rounded,
                  title: 'الأذكار',
                  subtitle: 'ذكر مختار يصلك على مدار اليوم',
                  kind: ReminderKind.zikr,
                  busy: _busy,
                  onToggle: _toggleReminder,
                  onInterval: _setInterval,
                  onSample: _sample,
                ),
                SizedBox(height: kFormPaddingAllNormal.h),
                _ReminderCard(
                  icon: Icons.menu_book_rounded,
                  title: 'الأحاديث',
                  subtitle: 'حديث من الأربعين النووية',
                  kind: ReminderKind.hadith,
                  busy: _busy,
                  onToggle: _toggleReminder,
                  onInterval: _setInterval,
                  onSample: _sample,
                ),
                SizedBox(height: kFormPaddingAllNormal.h),
                _ReminderCard(
                  icon: Icons.import_contacts_rounded,
                  title: 'الآيات',
                  subtitle: 'آية من كتاب الله',
                  kind: ReminderKind.ayah,
                  busy: _busy,
                  onToggle: _toggleReminder,
                  onInterval: _setInterval,
                  onSample: _sample,
                ),
                SizedBox(height: kScreenPaddingNormal.h),
                const _SectionLabel('أوقات التذكير'),
                SizedBox(height: kFormPaddingAllNormal.h),
                _ActiveWindowCard(
                  start: ReminderScheduler.startHour,
                  end: ReminderScheduler.endHour,
                  onTap: (isStart) => _setHour(isStart: isStart),
                ),
                SizedBox(height: kScreenPaddingNormal.h),
                const _SectionLabel('إشعار دائم'),
                SizedBox(height: kFormPaddingAllNormal.h),
                _SimpleToggleCard(
                  icon: Icons.picture_in_picture_alt_rounded,
                  title: 'الذكر العائم فوق التطبيقات',
                  subtitle:
                      'فقاعة ذكر تظهر فوق أي تطبيق، وتعمل والتطبيق مغلق',
                  value: _overlayOn,
                  onChanged: _toggleOverlay,
                ),
                SizedBox(height: kFormPaddingAllLarge.h),
                _SimpleToggleCard(
                  icon: Icons.favorite_rounded,
                  title: 'الصلاة على النبي ﷺ',
                  subtitle: 'إشعار مقيم لا يُمسح، بلا صوت ولا إزعاج',
                  value: ReminderScheduler.isSallyEnabled,
                  onChanged: _toggleSally,
                ),
                SizedBox(height: kScreenPaddingNormal.h),
                _StatusFooter(pending: _pending),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final onGreen = AppColor.appBarTextColor.themeColor;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 172.h,
      elevation: 0,
      backgroundColor: AppColor.primaryColor.themeColor,
      iconTheme: IconThemeData(color: AppColor.appBarIconsColor.themeColor),
      // FlexibleSpaceBar وحده يملك العنوان: وضع title على SliverAppBar أيضًا
      // كان يُظهره مرتين وهو مبسوط.
      flexibleSpace: IslamicHeaderBackground(
        child: FlexibleSpaceBar(
          centerTitle: true,
          titlePadding: EdgeInsets.only(bottom: kFormPaddingAllLarge.h),
          title: Text(
            'التنبيهات',
            style: const TextStyle().semiBoldStyle(fontSize: 16).customColor(onGreen),
          ),
          background: SafeArea(
            child: Padding(
              // مساحة سفلية تُخلي مكان العنوان المتحرك حتى لا يتراكب معه
              padding: EdgeInsets.fromLTRB(
                kScreenPaddingNormal.w,
                0,
                kScreenPaddingNormal.w,
                42.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_active_outlined,
                      size: 30.r, color: AppColor.rateColor.themeColor),
                  SizedBox(height: kFormPaddingAllNormal.h),
                  Text(
                    'تصلك في مواعيدها حتى والتطبيق مغلق',
                    textAlign: TextAlign.center,
                    style: const TextStyle()
                        .mediumStyle(fontSize: 12)
                        .customColor(AppColor.rateColor.themeColor),
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

// ---------------------------------------------------------------- المكوّنات

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: kFormPaddingAllSmall.w),
      child: Text(
        text,
        style: const TextStyle()
            .semiBoldStyle(fontSize: 13)
            .customColor(AppColor.textSecondaryDark.themeColor),
      ),
    );
  }
}

/// غلاف البطاقة الموحّد — سطح مرتفع بحدود خفيفة، يتبع الوضع الليلي.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(kFormPaddingAllLarge.w),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor.themeColor,
        borderRadius: BorderRadius.circular(kCardRadius.r),
        border: Border.all(color: AppColor.borderColor.themeColor),
      ),
      child: child,
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon, this.active = false});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final green = AppColor.primaryColor.themeColor;
    return Container(
      width: 42.r,
      height: 42.r,
      decoration: BoxDecoration(
        color: active
            ? green.withValues(alpha: 0.14)
            : AppColor.grayScaleColor.themeColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        icon,
        size: 22.r,
        color: active ? green : AppColor.hintColor.themeColor,
      ),
    );
  }
}

/// لوحة الأذونات الناقصة. لا تُعرض إطلاقًا حين يكون كل شيء ممنوحًا — لا
/// معنى لإظهار قائمة أذونات خضراء دائمة.
class _PermissionsPanel extends StatelessWidget {
  const _PermissionsPanel({required this.missing, required this.onFix});

  final List<AppPermissionState> missing;
  final ValueChanged<AppPermissionKind> onFix;

  static const Map<AppPermissionKind, (IconData, String, String)> _copy = {
    AppPermissionKind.notifications: (
      Icons.notifications_active_rounded,
      'إذن الإشعارات',
      'بدونه لن يظهر أي تنبيه على الجهاز مهما ضبطت الإعدادات',
    ),
    AppPermissionKind.exactAlarm: (
      Icons.alarm_on_rounded,
      'المنبهات الدقيقة',
      'يجعل الأذان والتذكيرات تصل في وقتها بدل تأخير قد يبلغ ساعة',
    ),
    AppPermissionKind.batteryOptimization: (
      Icons.battery_saver_rounded,
      'استثناء من توفير الطاقة',
      'يمنع النظام من إسقاط التنبيهات أثناء إغلاق التطبيق',
    ),
    AppPermissionKind.location: (
      Icons.location_on_rounded,
      'الموقع',
      'لحساب مواقيت الصلاة والأذان في مدينتك',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final gold = AppColor.goldDeepColor.themeColor;

    return Container(
      padding: EdgeInsets.all(kFormPaddingAllLarge.w),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(kCardRadius.r),
        border: Border.all(color: gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 20.r, color: gold),
              SizedBox(width: kFormPaddingAllNormal.w),
              Expanded(
                child: Text(
                  'أذونات مطلوبة',
                  style: const TextStyle()
                      .semiBoldStyle(fontSize: 14)
                      .primaryTextColor(),
                ),
              ),
            ],
          ),
          SizedBox(height: kFormPaddingAllSmall.h),
          Text(
            'التنبيهات لن تعمل والتطبيق مغلق قبل منح ما يلي:',
            style: const TextStyle()
                .mediumStyle(fontSize: 11)
                .customColor(AppColor.textSecondaryDark.themeColor),
          ),
          SizedBox(height: kFormPaddingAllNormal.h),
          ...missing.map((state) {
            final copy = _copy[state.kind]!;
            return Padding(
              padding: EdgeInsets.only(top: kFormPaddingAllNormal.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(copy.$1, size: 18.r, color: gold),
                  SizedBox(width: kFormPaddingAllNormal.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          copy.$2,
                          style: const TextStyle()
                              .semiBoldStyle(fontSize: 12.5)
                              .primaryTextColor(),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          copy.$3,
                          style: const TextStyle()
                              .mediumStyle(fontSize: 10.5)
                              .customColor(AppColor.hintColor.themeColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: kFormPaddingAllNormal.w),
                  TextButton(
                    onPressed: () => onFix(state.kind),
                    style: TextButton.styleFrom(
                      minimumSize: Size(56.w, 32.h),
                      padding:
                          EdgeInsets.symmetric(horizontal: kFormPaddingAllNormal.w),
                      backgroundColor: gold.withValues(alpha: 0.16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text(
                      'تفعيل',
                      style: const TextStyle()
                          .semiBoldStyle(fontSize: 11.5)
                          .customColor(gold),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// بطاقة تذكير: مفتاح + خيارات الفترة تظهر عند التفعيل فقط.
class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.busy,
    required this.onToggle,
    required this.onInterval,
    required this.onSample,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ReminderKind kind;
  final bool busy;
  final void Function(ReminderKind, bool) onToggle;
  final void Function(ReminderKind, int) onInterval;
  final void Function(ReminderKind) onSample;

  @override
  Widget build(BuildContext context) {
    final enabled = ReminderScheduler.isEnabled(kind);
    final green = AppColor.primaryColor.themeColor;

    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              _LeadingIcon(icon: icon, active: enabled),
              SizedBox(width: kFormPaddingAllLarge.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle()
                          .semiBoldStyle(fontSize: 14.5)
                          .primaryTextColor(),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: const TextStyle()
                          .mediumStyle(fontSize: 11)
                          .customColor(AppColor.hintColor.themeColor),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                activeThumbColor: Colors.white,
                activeTrackColor: green,
                onChanged: busy ? null : (v) => onToggle(kind, v),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                enabled ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: kFormPaddingAllLarge.h),
                Divider(height: 1, color: AppColor.dividerColor.themeColor),
                SizedBox(height: kFormPaddingAllLarge.h),
                Row(
                  children: [
                    Text(
                      'كل',
                      style: const TextStyle()
                          .semiBoldStyle(fontSize: 12)
                          .customColor(AppColor.textSecondaryDark.themeColor),
                    ),
                    SizedBox(width: kFormPaddingAllNormal.w),
                    Expanded(
                      child: SizedBox(
                        height: 32.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: kReminderIntervalsMinutes.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: kFormPaddingAllSmall.w + 2),
                          itemBuilder: (_, i) => _IntervalChip(
                            minutes: kReminderIntervalsMinutes[i],
                            selected:
                                ReminderScheduler.intervalIndex(kind) == i,
                            onTap: () => onInterval(kind, i),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: kFormPaddingAllNormal.h),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => onSample(kind),
                    icon: Icon(Icons.notifications_none_rounded,
                        size: 18.r, color: green),
                    label: Text(
                      'عرض مثال الآن',
                      style: const TextStyle()
                          .semiBoldStyle(fontSize: 12)
                          .customColor(green),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 32.h),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _IntervalChip extends StatelessWidget {
  const _IntervalChip({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  String get _label {
    if (minutes < 60) return '$minutes د';
    if (minutes % 60 == 0) return '${minutes ~/ 60} س';
    return '${(minutes / 60).toStringAsFixed(1)} س';
  }

  @override
  Widget build(BuildContext context) {
    final green = AppColor.primaryColor.themeColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: kFormPaddingAllLarge.w),
        decoration: BoxDecoration(
          color: selected ? green : AppColor.grayScaleColor.themeColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? green : AppColor.borderColor.themeColor,
          ),
        ),
        child: Text(
          _label,
          style: const TextStyle().semiBoldStyle(fontSize: 11.5).customColor(
                selected ? Colors.white : AppColor.textSecondaryDark.themeColor,
              ),
        ),
      ),
    );
  }
}

/// نافذة الهدوء: خارجها لا يُجدول أي تذكير.
class _ActiveWindowCard extends StatelessWidget {
  const _ActiveWindowCard({
    required this.start,
    required this.end,
    required this.onTap,
  });

  final int start;
  final int end;
  final ValueChanged<bool> onTap;

  static String _fmt(int hour) {
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$h12:00 ${hour < 12 ? 'ص' : 'م'}';
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              const _LeadingIcon(icon: Icons.bedtime_outlined, active: true),
              SizedBox(width: kFormPaddingAllLarge.w),
              Expanded(
                child: Text(
                  'لا تصلك التذكيرات خارج هذه الفترة',
                  style: const TextStyle()
                      .mediumStyle(fontSize: 12)
                      .customColor(AppColor.textSecondaryDark.themeColor),
                ),
              ),
            ],
          ),
          SizedBox(height: kFormPaddingAllLarge.h),
          Row(
            children: [
              Expanded(
                child: _HourBox(
                  label: 'من',
                  value: _fmt(start),
                  onTap: () => onTap(true),
                ),
              ),
              SizedBox(width: kFormPaddingAllNormal.w),
              Expanded(
                child: _HourBox(
                  label: 'إلى',
                  value: _fmt(end),
                  onTap: () => onTap(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HourBox extends StatelessWidget {
  const _HourBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kFormRadius.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: kFormPaddingAllLarge.w,
          vertical: kFormPaddingAllNormal.h + 2,
        ),
        decoration: BoxDecoration(
          color: AppColor.grayScaleColor.themeColor,
          borderRadius: BorderRadius.circular(kFormRadius.r),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle()
                  .mediumStyle(fontSize: 11)
                  .customColor(AppColor.hintColor.themeColor),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle()
                  .semiBoldStyle(fontSize: 13)
                  .primaryTextColor(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleToggleCard extends StatelessWidget {
  const _SimpleToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          _LeadingIcon(icon: icon, active: value),
          SizedBox(width: kFormPaddingAllLarge.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle()
                      .semiBoldStyle(fontSize: 14.5)
                      .primaryTextColor(),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: const TextStyle()
                      .mediumStyle(fontSize: 11)
                      .customColor(AppColor.hintColor.themeColor),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColor.primaryColor.themeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// يعرض عدد التذكيرات المسجّلة لدى النظام فعلًا — دليل ملموس على أن
/// الجدولة تمت، لا مجرد مفتاح أخضر.
class _StatusFooter extends StatelessWidget {
  const _StatusFooter({required this.pending});

  final int pending;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          pending > 0 ? Icons.check_circle_outline_rounded : Icons.info_outline,
          size: 16.r,
          color: pending > 0
              ? AppColor.successColor.themeColor
              : AppColor.hintColor.themeColor,
        ),
        SizedBox(width: kFormPaddingAllNormal.w),
        Expanded(
          child: Text(
            pending > 0
                ? 'مسجَّل لدى النظام: $pending تذكيرًا — تصلك حتى والتطبيق مغلق.'
                : 'لا توجد تذكيرات مجدولة حاليًا.',
            style: const TextStyle()
                .mediumStyle(fontSize: 11)
                .customColor(AppColor.hintColor.themeColor),
          ),
        ),
      ],
    );
  }
}
