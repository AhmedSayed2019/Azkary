import 'dart:async';

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/widgets/islamic_header_background.dart';
import 'package:azkark/features/prayer/azan_scheduler.dart';
import 'package:azkark/features/prayer/prayer_times_screen.dart';
import 'package:azkark/features/prayer/prayer_times_service.dart';
import 'package:azkark/widgets/arabic_numbers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

/// قسم "مواقيت الصلاة" في الشاشة الرئيسية كشريحة محتوى (Sliver):
/// التاريخ + عدّاد الصلاة القادمة + بطاقة الصلوات العائمة، يتمرر ويختفي
/// خلف الشريط المثبت (الذي تبنيه الشاشة الأم) عند السحب.
class AzanSection extends StatefulWidget {
  const AzanSection({super.key});

  @override
  State<AzanSection> createState() => _AzanSectionState();
}

class _AzanSectionState extends State<AzanSection> {
  final PrayerTimesService _service = PrayerTimesService();

  Timer? _ticker;
  DateTime _now = DateTime.now();
  PrayerDay? _day;
  bool _ready = false;
  bool _refreshingLocation = false;

  static const _icons = <PrayerId, IconData>{
    PrayerId.fajr: Icons.nights_stay_rounded,
    PrayerId.dhuhr: Icons.wb_sunny_outlined,
    PrayerId.asr: Icons.wb_sunny_rounded,
    PrayerId.maghrib: Icons.wb_twilight_rounded,
    PrayerId.isha: Icons.dark_mode_rounded,
  };

  @override
  void initState() {
    super.initState();
    _init();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      final day = _day;
      // أعد حساب مواقيت اليوم فقط عند دخول وقت صلاة جديد، لا كل ثانية —
      // العدّاد نفسه (المتبقي/الدائرة) يُعاد رسمه من _now بلا إعادة حساب.
      if (day == null || !now.isBefore(day.next.time)) {
        setState(() {
          _now = now;
          _day = _service.compute(now: now);
        });
      } else {
        setState(() => _now = now);
      }
    });
  }

  Future<void> _init() async {
    await _service.loadCache();
    if (mounted) {
      setState(() {
        _day = _service.compute(now: _now);
        _ready = true;
      });
    }
    // تحديث الموقع في الخلفية دون حجب أول عرض
    final changed = await _service.refreshLocation();
    if (changed && mounted) setState(() => _day = _service.compute(now: _now));
    // جدولة صوت الأذان القادمة وفق أحدث موقع/مواقيت
    AzanScheduler.reschedule(service: _service);
  }

  Future<void> _refreshLocation() async {
    setState(() => _refreshingLocation = true);
    await _service.refreshLocation();
    if (!mounted) return;
    setState(() {
      _refreshingLocation = false;
      _day = _service.compute(now: _now);
    });
    AzanScheduler.reschedule(service: _service);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _openPrayerTimes() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen()));

  @override
  Widget build(BuildContext context) {
    final day = _day;

    return SliverToBoxAdapter(
      child: (!_ready || day == null)
          ? const IslamicHeaderBackground(
              child: SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(color: Colors.white70)),
              ),
            )
          : GestureDetector(
              onTap: _openPrayerTimes,
              // بطاقة الصلوات عائمة: نصفها فوق الأخضر ونصفها على خلفية الصفحة
              child: Stack(
                children: [
                  Column(
                    children: [
                      IslamicHeaderBackground(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _CountdownHeader(
                              day: day,
                              now: _now,
                              refreshingLocation: _refreshingLocation,
                              onRefreshLocation: _refreshLocation,
                            ),
                            // مساحة خضراء تجلس خلف النصف العلوي من البطاقة
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                      // مساحة شفافة يطفو فوقها النصف السفلي من البطاقة
                      SizedBox(height: 52.h),
                    ],
                  ),
                  Positioned(
                    left: kScreenPaddingNormal.w,
                    right: kScreenPaddingNormal.w,
                    bottom: 0,
                    child: _PrayerRow(day: day, icons: _icons),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CountdownHeader extends StatelessWidget {
  const _CountdownHeader({
    required this.day,
    required this.now,
    required this.refreshingLocation,
    required this.onRefreshLocation,
  });

  final PrayerDay day;
  final DateTime now;
  final bool refreshingLocation;
  final VoidCallback onRefreshLocation;

  @override
  Widget build(BuildContext context) {
    HijriCalendar.setLocal(context.locale.languageCode == 'ar' ? 'ar' : 'en');
    final hijri = HijriCalendar.now();
    final gregorian = DateFormat('d MMMM yyyy', context.locale.languageCode).format(now);

    final remaining = day.remaining(now);
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);
    final s = remaining.inSeconds.remainder(60);
    final countdown = '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'.toArabicNumbers;

    final isPm = day.next.time.hour >= 12;
    final hour12 = day.next.time.hour % 12 == 0 ? 12 : day.next.time.hour % 12;
    final clock = '$hour12:${day.next.time.minute.toString().padLeft(2, '0')}'.toArabicNumbers;

    final Color gold = AppColor.rateColor.themeColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(kScreenPaddingNormal.w, kFormPaddingAllSmall.h, kScreenPaddingNormal.w, kFormPaddingAllLarge.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // سطر التاريخ: الهجري بالذهبي ثم الميلادي باهتًا
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${hijri.toFormat("d MMMM yyyy")} هـ', style: const TextStyle().semiBoldStyle(fontSize: 12).customColor(gold)),
              Text('  •  ', style: const TextStyle().mediumStyle(fontSize: 12).customColor(Colors.white38)),
              Text(gregorian, style: const TextStyle().mediumStyle(fontSize: 11).customColor(Colors.white54)),
            ],
          ),
          SizedBox(height: kFormPaddingAllLarge.h),
          Row(
            children: [
              // في RTL: هذا العمود يظهر يمينًا — اسم الصلاة القادمة والموقع
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الصلاة القادمة', style: const TextStyle().mediumStyle(fontSize: 11).customColor(Colors.white60)),
                    SizedBox(height: 2.h),
                    Text(day.next.name, style: const TextStyle().boldStyle().customColor(Colors.white).copyWith(fontSize: 32.sp, height: 1.2)),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.white70),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            day.locationName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle().mediumStyle(fontSize: 12).customColor(Colors.white70),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        // زر تحديث الموقع من GPS — يُوقف فقاعة الضغط حتى لا يفتح شاشة المواقيت
                        InkResponse(
                          onTap: refreshingLocation ? null : onRefreshLocation,
                          radius: 18,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                            child: refreshingLocation
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                                  )
                                : const Icon(Icons.my_location, size: 12, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: kFormPaddingAllLarge.w),
              // وفي الجهة الأخرى: حلقة العدّاد المصغّرة
              SizedBox(
                width: 90.r,
                height: 90.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90.r,
                      height: 90.r,
                      child: CircularProgressIndicator(
                        value: day.progress(now),
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(gold),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(clock, style: const TextStyle().boldStyle().customColor(Colors.white).copyWith(fontSize: 20.sp, height: 1.1)),
                        Text(isPm ? 'مساءً' : 'صباحاً', style: const TextStyle().mediumStyle(fontSize: 9).customColor(Colors.white70)),
                        SizedBox(height: 3.h),
                        Text(countdown, style: const TextStyle().semiBoldStyle(fontSize: 10).customColor(gold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({required this.day, required this.icons});

  final PrayerDay day;
  final Map<PrayerId, IconData> icons;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: kFormPaddingAllNormal.h, horizontal: kFormPaddingAllSmall.w),
      decoration: BoxDecoration(
        color: AppColor.cardColor.themeColor,
        borderRadius: BorderRadius.circular(kFormRadius * 1.6),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          for (final slot in day.five)
            Expanded(child: _PrayerRowItem(slot: slot, active: slot.id == day.next.id, icon: icons[slot.id]!)),
        ],
      ),
    );
  }
}

class _PrayerRowItem extends StatelessWidget {
  const _PrayerRowItem({required this.slot, required this.active, required this.icon});

  final PrayerSlot slot;
  final bool active;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final hour12 = slot.time.hour % 12 == 0 ? 12 : slot.time.hour % 12;
    final time = '$hour12:${slot.time.minute.toString().padLeft(2, '0')}'.toArabicNumbers;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: kFormPaddingAllNormal.h),
      decoration: BoxDecoration(
        color: active ? AppColor.primaryColor.themeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(kFormRadius * 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: active ? AppColor.rateColor.themeColor : AppColor.primaryColor.themeColor),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(slot.name, maxLines: 1, style: const TextStyle().semiBoldStyle(fontSize: 11).customColor(active ? Colors.white : AppColor.textColor.themeColor)),
          ),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              maxLines: 1,
              style: const TextStyle().semiBoldStyle(fontSize: 11).customColor(active ? AppColor.rateColor.themeColor : AppColor.hintColor.themeColor),
            ),
          ),
        ],
      ),
    );
  }
}
