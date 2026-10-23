// شاشة التنبيهات — أذونات + تذكيرات مجدولة.
//
// النسخة السابقة كانت أربع بطاقات متطابقة منسوخة يدويًا (١٠١٣ سطرًا) تقرأ
// `getValue("darkMode")` في كل سطر لون، وتُسجّل مهام WorkManager مباشرة من
// داخل `onChanged`. أُعيدت بناءً على [ReminderScheduler] و[AppPermissions]:
// المفتاح لا يُقلب إلا بعد التأكد من إذن الإشعارات وإتمام الجدولة فعليًا،
// والألوان من `AppColor` فتتبع الوضع الليلي تلقائيًا.

import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/core/utils/permissions/app_permissions.dart';
import 'package:azkark/features/notifications/logic/overlay_palette.dart';
import 'package:azkark/features/notifications/logic/reminder_scheduler.dart';
import 'package:azkark/features/notifications/logic/overlay_scheduler.dart';
import 'package:azkark/features/notifications/views/reminder_pill.dart';
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

  /// إذن «العرض فوق التطبيقات». يُقرأ مرة عند كل عودة للمقدمة بدل قراءته
  /// داخل build: الفحص عبر قناة نظام، لا يصلح لدالة بناء متزامنة.
  bool _overlayAllowed = false;

  /// لون الحبّة العائمة. في SharedPreferences لا في Hive — تقرؤه عزلة
  /// المنبّه — فيُقرأ هنا مرة ويُحتفظ به للبناء المتزامن.
  OverlayPillColor _pillColor = kDefaultOverlayPillColor;

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
    final overlayAllowed = await OverlayScheduler.hasPermission();
    final pillColor = await OverlayScheduler.pillColor();
    if (!mounted) return;
    setState(() {
      _permissions = permissions;
      _pending = pending;
      _overlayAllowed = overlayAllowed;
      _pillColor = pillColor;
    });
  }

  /// أي نوع يُعرض كنافذة عائمة؟ اختيار اللون بلا نافذة عائمة زرٌّ لا يفعل
  /// شيئًا، فالقسم يظهر بظهور أول نوع عائم ويختفي باختفائه.
  bool get _hasFloating => OverlayScheduler.floatingKinds.isNotEmpty;

  Future<void> _setPillColor(OverlayPillColor color) async {
    if (color == _pillColor) return;
    setState(() => _pillColor = color);
    await OverlayScheduler.setPillColor(color);
  }

  List<AppPermissionState> get _missing =>
      _permissions.where((p) => p.needsAttention).toList(growable: false);

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle().mediumStyle(fontSize: 13).colorWhite(),
          ),
          backgroundColor: error
              ? AppColor.errorColor.themeColor
              : AppColor.primaryColor.themeColor,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(kScreenPaddingNormal.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
  }

  /// تفعيل/تعطيل تذكير. لا نقلب المفتاح قبل إذن الإشعارات: بدونه تنجح
  /// الجدولة ولا يرى المستخدم شيئًا — وهو تمامًا ما كان يحدث سابقًا.
  Future<void> _toggleReminder(ReminderKind kind, bool value) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (value && !await AppPermissions.ensureNotifications()) {
        _toast('notif_need_permission'.tr(), error: true);
        return;
      }
      await ReminderScheduler.setEnabled(kind, value);
      if (value &&
          !await AppPermissions.isGranted(AppPermissionKind.exactAlarm)) {
        _toast('notif_enabled_exact_hint'.tr());
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

  /// «عرض مثال» يعرض ما اختاره المستخدم فعلًا لا إشعارًا دائمًا: زر يُظهر
  /// إشعارًا بينما الوضع «نافذة عائمة» يجعل المعاينة اختبارًا لشيء آخر.
  Future<void> _sample(ReminderKind kind) async {
    final mode = ReminderScheduler.deliveryOf(kind);
    var shown = false;
    String? failure;

    if (mode.hasNotification) {
      if (await AppPermissions.ensureNotifications()) {
        shown = await ReminderScheduler.showSample(kind) || shown;
      } else {
        failure = 'notif_need_permission'.tr();
      }
    }

    if (mode.hasFloating) {
      if (await OverlayScheduler.hasPermission()) {
        shown = await OverlayScheduler.showSample(kind) || shown;
      } else {
        failure = 'overlay_needs_permission'.tr();
      }
    }

    if (failure != null) {
      _toast(failure, error: true);
    } else if (!shown) {
      _toast('notif_preview_failed'.tr(), error: true);
    }
  }

  /// طريقة عرض نوع بعينه. كل وضع يحتاج إذنه: الإشعار إذن الإشعارات،
  /// والنافذة العائمة إذن «العرض فوق التطبيقات» — وهو لا يُمنح بحوار عادي
  /// بل من شاشة إعدادات مستقلة. لا نحفظ الاختيار قبل المنح، وإلا بقي
  /// معروضًا في الواجهة بينما لا يصل المستخدم شيء.
  Future<void> _setDelivery(ReminderKind kind, ReminderDelivery mode) async {
    if (_busy || mode == ReminderScheduler.deliveryOf(kind)) return;
    setState(() => _busy = true);
    try {
      if (mode.hasNotification && !await AppPermissions.ensureNotifications()) {
        _toast('notif_need_permission'.tr(), error: true);
        return;
      }
      if (mode.hasFloating && !await OverlayScheduler.hasPermission()) {
        if (!await OverlayScheduler.requestPermission()) {
          _toast('overlay_needs_permission'.tr(), error: true);
          return;
        }
      }
      await ReminderScheduler.setDelivery(kind, mode);
    } finally {
      if (mounted) setState(() => _busy = false);
      await _refresh();
    }
  }

  Future<void> _toggleSally(bool value) async {
    if (value && !await AppPermissions.ensureNotifications()) {
      _toast('notif_need_permission'.tr(), error: true);
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
      helpText: isStart ? 'reminder_start'.tr() : 'reminder_end'.tr(),
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
                _SectionLabel('reminders'.tr()),
                SizedBox(height: kFormPaddingAllNormal.h),
                _ReminderCard(
                  icon: Icons.self_improvement_rounded,
                  title: 'adhkar'.tr(),
                  subtitle: 'adhkar_desc'.tr(),
                  kind: ReminderKind.zikr,
                  busy: _busy,
                  overlayAllowed: _overlayAllowed,
                  onToggle: _toggleReminder,
                  onInterval: _setInterval,
                  onDelivery: _setDelivery,
                  onSample: _sample,
                ),
                SizedBox(height: kFormPaddingAllNormal.h),
                _ReminderCard(
                  icon: Icons.menu_book_rounded,
                  title: 'ahadith'.tr(),
                  subtitle: 'ahadith_desc'.tr(),
                  kind: ReminderKind.hadith,
                  busy: _busy,
                  overlayAllowed: _overlayAllowed,
                  onToggle: _toggleReminder,
                  onInterval: _setInterval,
                  onDelivery: _setDelivery,
                  onSample: _sample,
                ),
                SizedBox(height: kFormPaddingAllNormal.h),
                _ReminderCard(
                  icon: Icons.import_contacts_rounded,
                  title: 'ayat'.tr(),
                  subtitle: 'ayat_desc'.tr(),
                  kind: ReminderKind.ayah,
                  busy: _busy,
                  overlayAllowed: _overlayAllowed,
                  onToggle: _toggleReminder,
                  onInterval: _setInterval,
                  onDelivery: _setDelivery,
                  onSample: _sample,
                ),
                if (_hasFloating) ...[
                  SizedBox(height: kScreenPaddingNormal.h),
                  _SectionLabel('overlay_color'.tr()),
                  SizedBox(height: kFormPaddingAllNormal.h),
                  _OverlayColorCard(
                    selected: _pillColor,
                    onPick: _setPillColor,
                  ),
                ],
                SizedBox(height: kScreenPaddingNormal.h),
                _SectionLabel('reminder_times'.tr()),
                SizedBox(height: kFormPaddingAllNormal.h),
                _ActiveWindowCard(
                  start: ReminderScheduler.startHour,
                  end: ReminderScheduler.endHour,
                  onTap: (isStart) => _setHour(isStart: isStart),
                ),
                SizedBox(height: kScreenPaddingNormal.h),
                _SectionLabel('persistent_notification'.tr()),
                SizedBox(height: kFormPaddingAllNormal.h),
                _SimpleToggleCard(
                  icon: Icons.favorite_rounded,
                  title: 'sally_channel_name'.tr(),
                  subtitle: 'sally_toggle_desc'.tr(),
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
            'alerts'.tr(),
            style: const TextStyle()
                .semiBoldStyle(fontSize: 16)
                .customColor(onGreen),
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
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 30.r,
                    color: AppColor.rateColor.themeColor,
                  ),
                  SizedBox(height: kFormPaddingAllNormal.h),
                  Text(
                    'alerts_desc'.tr(),
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

  // لم تعد const: tr() تُقرأ عند البناء لا عند الترجمة
  static Map<AppPermissionKind, (IconData, String, String)> _copy = {
    AppPermissionKind.notifications: (
      Icons.notifications_active_rounded,
      'perm_notifications'.tr(),
      'perm_notifications_desc'.tr(),
    ),
    AppPermissionKind.exactAlarm: (
      Icons.alarm_on_rounded,
      'perm_exact_alarms'.tr(),
      'perm_exact_alarms_desc'.tr(),
    ),
    AppPermissionKind.fullScreen: (
      Icons.fullscreen_rounded,
      'perm_full_screen'.tr(),
      'perm_full_screen_desc'.tr(),
    ),
    AppPermissionKind.batteryOptimization: (
      Icons.battery_saver_rounded,
      'perm_battery'.tr(),
      'perm_battery_desc'.tr(),
    ),
    AppPermissionKind.location: (
      Icons.location_on_rounded,
      'perm_location'.tr(),
      'perm_location_desc'.tr(),
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
                  'perms_required'.tr(),
                  style: const TextStyle()
                      .semiBoldStyle(fontSize: 14)
                      .primaryTextColor(),
                ),
              ),
            ],
          ),
          SizedBox(height: kFormPaddingAllSmall.h),
          Text(
            'perms_required_desc'.tr(),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: kFormPaddingAllNormal.w,
                      ),
                      backgroundColor: gold.withValues(alpha: 0.16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'enable'.tr(),
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
    required this.overlayAllowed,
    required this.onToggle,
    required this.onInterval,
    required this.onDelivery,
    required this.onSample,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ReminderKind kind;
  final bool busy;

  /// إذن «العرض فوق التطبيقات». يُظهر تنبيهًا تحت المُحدِّد حين يكون
  /// المستخدم قد اختار وضعًا عائمًا ثم سحب الإذن من إعدادات النظام —
  /// وإلا بدا الخيار مفعّلًا بينما لا تظهر أي نافذة.
  final bool overlayAllowed;
  final void Function(ReminderKind, bool) onToggle;
  final void Function(ReminderKind, int) onInterval;
  final void Function(ReminderKind, ReminderDelivery) onDelivery;
  final void Function(ReminderKind) onSample;

  @override
  Widget build(BuildContext context) {
    final enabled = ReminderScheduler.isEnabled(kind);
    final delivery = ReminderScheduler.deliveryOf(kind);
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
            crossFadeState: enabled
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: kFormPaddingAllLarge.h),
                Divider(height: 1, color: AppColor.dividerColor.themeColor),
                SizedBox(height: kFormPaddingAllLarge.h),
                Row(
                  children: [
                    Text(
                      'every'.tr(),
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
                // النافذة العائمة إضافة أندرويد خالصة (SYSTEM_ALERT_WINDOW)؛
                // على iOS لا مُحدِّد أصلًا، والإشعار هو الوضع الوحيد.
                if (Platform.isAndroid) ...[
                  SizedBox(height: kFormPaddingAllLarge.h),
                  Text(
                    'delivery_mode'.tr(),
                    style: const TextStyle()
                        .semiBoldStyle(fontSize: 12)
                        .customColor(AppColor.textSecondaryDark.themeColor),
                  ),
                  SizedBox(height: kFormPaddingAllNormal.h),
                  Row(
                    children: [
                      for (final mode in ReminderDelivery.values) ...[
                        Expanded(
                          child: _DeliveryChip(
                            mode: mode,
                            selected: delivery == mode,
                            onTap: busy ? null : () => onDelivery(kind, mode),
                          ),
                        ),
                        if (mode != ReminderDelivery.values.last)
                          SizedBox(width: kFormPaddingAllSmall.w + 2),
                      ],
                    ],
                  ),
                  if (delivery.hasFloating && !overlayAllowed) ...[
                    SizedBox(height: kFormPaddingAllSmall.h),
                    Text(
                      'overlay_needs_permission'.tr(),
                      style: const TextStyle()
                          .mediumStyle(fontSize: 10.5)
                          .customColor(AppColor.errorColor.themeColor),
                    ),
                  ],
                ],
                SizedBox(height: kFormPaddingAllNormal.h),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => onSample(kind),
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      size: 18.r,
                      color: green,
                    ),
                    label: Text(
                      'show_example_now'.tr(),
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

/// خيار واحد من مُحدِّد طريقة العرض. أوسع من [_IntervalChip] وبأيقونة:
/// الفرق بين «إشعار» و«عائم» سلوكي لا رقمي، فالأيقونة تُغني عن قراءة النص.
class _DeliveryChip extends StatelessWidget {
  const _DeliveryChip({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ReminderDelivery mode;
  final bool selected;
  final VoidCallback? onTap;

  (IconData, String) get _copy => switch (mode) {
    ReminderDelivery.notification => (
      Icons.notifications_none_rounded,
      'delivery_notification'.tr(),
    ),
    ReminderDelivery.floating => (
      Icons.picture_in_picture_alt_rounded,
      'delivery_floating'.tr(),
    ),
    ReminderDelivery.both => (Icons.done_all_rounded, 'delivery_both'.tr()),
  };

  @override
  Widget build(BuildContext context) {
    final green = AppColor.primaryColor.themeColor;
    final (icon, label) = _copy;
    final foreground = selected
        ? Colors.white
        : AppColor.textSecondaryDark.themeColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: kFormPaddingAllNormal.h),
        decoration: BoxDecoration(
          color: selected ? green : AppColor.grayScaleColor.themeColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? green : AppColor.borderColor.themeColor,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18.r, color: foreground),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle()
                  .semiBoldStyle(fontSize: 10.5)
                  .customColor(foreground),
            ),
          ],
        ),
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
    if (minutes < 60) return 'minutes_short'.tr(namedArgs: {'n': '$minutes'});
    if (minutes % 60 == 0)
      return 'hours_short'.tr(namedArgs: {'n': '${minutes ~/ 60}'});
    return 'hours_short'.tr(
      namedArgs: {'n': (minutes / 60).toStringAsFixed(1)},
    );
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
          style: const TextStyle()
              .semiBoldStyle(fontSize: 11.5)
              .customColor(
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
    return '$h12:00 ${hour < 12 ? 'am_short'.tr() : 'pm_short'.tr()}';
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
                  'outside_window_note'.tr(),
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
                  label: 'from'.tr(),
                  value: _fmt(start),
                  onTap: () => onTap(true),
                ),
              ),
              SizedBox(width: kFormPaddingAllNormal.w),
              Expanded(
                child: _HourBox(
                  label: 'to'.tr(),
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

/// اختيار لون الحبّة العائمة: صفٌّ لكل لون، فيه الحبّة نفسها لا مربّع لون.
///
/// المعاينة هي [ReminderPill] عينها التي ترسمها عزلة النافذة — لا نسخة
/// تشبهها: ما يراه المستخدم هنا هو حرفيًا ما سيظهر فوق تطبيقاته.
class _OverlayColorCard extends StatelessWidget {
  const _OverlayColorCard({required this.selected, required this.onPick});

  final OverlayPillColor selected;
  final ValueChanged<OverlayPillColor> onPick;

  /// نصّ المعاينة عربيّ مهما كانت لغة الواجهة: محتوى النافذة نفسه عربيّ
  /// (الأذكار والأحاديث والآيات لا تُترجم)، فمعاينةٌ بالإنجليزية تُري
  /// المستخدم سطرًا لن يراه قط.
  static const String _sample = 'لا إله إلا الله وحده لا شريك له';

  @override
  Widget build(BuildContext context) {
    return _Card(
      // RadioGroup لا groupValue/onChanged على كل زر: الأخيران متقاعدان
      // منذ Flutter 3.32، والمجموعة هي التي تحمل القيمة الآن.
      child: RadioGroup<OverlayPillColor>(
        groupValue: selected,
        onChanged: (picked) {
          if (picked != null) onPick(picked);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'overlay_color_desc'.tr(),
              style: const TextStyle()
                  .mediumStyle(fontSize: 11)
                  .customColor(AppColor.hintColor.themeColor),
            ),
            SizedBox(height: kFormPaddingAllLarge.h),
            for (final color in OverlayPillColor.values) ...[
              Row(
                children: [
                  // الحبّة تتقولب على نصّها، فـExpanded حولها ليتحاذى
                  // مؤشّر الاختيار في الصفوف كلها مهما اختلف عرضها.
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: ReminderPill(
                        text: _sample,
                        color: color,
                        onTap: () => onPick(color),
                      ),
                    ),
                  ),
                  SizedBox(width: kFormPaddingAllNormal.w),
                  Radio<OverlayPillColor>(
                    value: color,
                    activeColor: color.color,
                  ),
                ],
              ),
              if (color != OverlayPillColor.values.last)
                SizedBox(height: kFormPaddingAllNormal.h),
            ],
          ],
        ),
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
                ? 'registered_reminders'.tr(namedArgs: {'n': '$pending'})
                : 'no_reminders_scheduled'.tr(),
            style: const TextStyle()
                .mediumStyle(fontSize: 11)
                .customColor(AppColor.hintColor.themeColor),
          ),
        ),
      ],
    );
  }
}
