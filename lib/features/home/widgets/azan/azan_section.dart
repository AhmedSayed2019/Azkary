import 'dart:async';

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/features/prayer/prayer_times_screen.dart';
import 'package:azkark/features/prayer/prayer_times_service.dart';
import 'package:azkark/widgets/arabic_numbers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

/// قسم "مواقيت الصلاة" في الشاشة الرئيسية: عدّاد دائري للصلاة القادمة
/// فوق صف بمواقيت الصلوات الخمس، بحساب محلي بالكامل عبر [PrayerTimesService].
class AzanSection extends StatefulWidget {
  const AzanSection({super.key});

  @override
  State<AzanSection> createState() => _AzanSectionState();
}

class _AzanSectionState extends State<AzanSection> {
  final PrayerTimesService _service = PrayerTimesService();

  Timer? _ticker;
  DateTime _now = DateTime.now();
  bool _ready = false;

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
    // ثانية بثانية لتحديث العدّاد التنازلي والمؤشر الدائري
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  Future<void> _init() async {
    await _service.loadCache();
    if (mounted) setState(() => _ready = true);
    // تحديث الموقع في الخلفية دون حجب أول عرض
    final changed = await _service.refreshLocation();
    if (changed && mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final day = _service.compute(now: _now);

    return Container(
      margin: kScreenPadding.copyWith(bottom: 0),
      decoration: const BoxDecoration().radius(radius: kFormRadius),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CountdownHeader(day: day, now: _now),
              _PrayerRow(day: day, icons: _icons),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownHeader extends StatelessWidget {
  const _CountdownHeader({required this.day, required this.now});

  final PrayerDay day;
  final DateTime now;

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

    return Container(
      width: double.infinity,
      color: AppColor.primaryColor.themeColor,
      padding: EdgeInsets.symmetric(vertical: kFormPaddingAllLarge.h, horizontal: kFormPaddingAllLarge.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${hijri.toFormat("d MMMM yyyy")}  •  $gregorian',
            style: const TextStyle().mediumStyle(fontSize: 11).customColor(Colors.white70),
          ),
          SizedBox(height: kFormPaddingAllLarge.h),
          SizedBox(
            width: 150.r,
            height: 150.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150.r,
                  height: 150.r,
                  child: CircularProgressIndicator(
                    value: day.progress(now),
                    strokeWidth: 7,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.rateColor.themeColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('الصلاة القادمة', style: const TextStyle().mediumStyle(fontSize: 10).customColor(Colors.white70)),
                    SizedBox(height: 2.h),
                    Text(clock, style: const TextStyle().boldStyle().customColor(Colors.white).copyWith(fontSize: 30.sp)),
                    Text(isPm ? 'مساءً' : 'صباحاً', style: const TextStyle().mediumStyle(fontSize: 10).customColor(Colors.white70)),
                    SizedBox(height: 4.h),
                    Text(countdown, style: const TextStyle().semiBoldStyle(fontSize: 11).customColor(AppColor.rateColor.themeColor)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: kFormPaddingAllNormal.h),
          Text(day.next.name, style: const TextStyle().boldStyle().customColor(Colors.white).copyWith(fontSize: 16.sp)),
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.white70),
              SizedBox(width: 4.w),
              Text(day.locationName, style: const TextStyle().mediumStyle(fontSize: 12).customColor(Colors.white70)),
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
      color: AppColor.cardColor.themeColor,
      padding: EdgeInsets.symmetric(vertical: kFormPaddingAllLarge.h, horizontal: kFormPaddingAllSmall.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final slot in day.five) _PrayerRowItem(slot: slot, active: slot.id == day.next.id, icon: icons[slot.id]!),
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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: kFormPaddingAllNormal.w, vertical: kFormPaddingAllSmall.h),
      decoration: BoxDecoration(
        color: active ? AppColor.primaryColor.themeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(kFormRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: active ? AppColor.rateColor.themeColor : AppColor.primaryColor.themeColor),
          SizedBox(height: 4.h),
          Text(slot.name, style: const TextStyle().mediumStyle(fontSize: 11).customColor(active ? Colors.white : AppColor.textColor.themeColor)),
          SizedBox(height: 2.h),
          Text(time, style: const TextStyle().semiBoldStyle(fontSize: 12).customColor(active ? Colors.white : AppColor.textColor.themeColor)),
        ],
      ),
    );
  }
}
