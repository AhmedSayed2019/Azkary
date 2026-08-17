import 'dart:async';

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/features/prayer/prayer_times_service.dart';
import 'package:azkark/widgets/arabic_numbers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// شاشة "مواقيت الصلاة" الكاملة: عدّاد تنازلي للصلاة القادمة، تصفّح
/// بين الأيام، وقائمة الصلوات الست مع تبديل صوت الأذان وتعليم "تم الصلاة".
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesService _service = PrayerTimesService();

  Timer? _ticker;
  DateTime _now = DateTime.now();
  int _dayOffset = 0;
  bool _ready = false;

  SharedPreferences? _prefs;
  final Map<PrayerId, bool> _soundEnabled = {};
  final Set<String> _doneKeys = {};

  static const _icons = <PrayerId, IconData>{
    PrayerId.fajr: Icons.nights_stay_rounded,
    PrayerId.sunrise: Icons.wb_twilight_rounded,
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
      setState(() => _now = DateTime.now());
    });
  }

  Future<void> _init() async {
    await _service.loadCache();
    _prefs = await SharedPreferences.getInstance();
    for (final id in PrayerId.values) {
      _soundEnabled[id] = _prefs!.getBool('prayer_sound_${id.name}') ?? true;
    }
    for (final key in _prefs!.getKeys()) {
      if (key.startsWith('prayer_done_') && (_prefs!.getBool(key) ?? false)) {
        _doneKeys.add(key.substring('prayer_done_'.length));
      }
    }
    if (mounted) setState(() => _ready = true);
    final changed = await _service.refreshLocation();
    if (changed && mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isDone(DateTime day, PrayerId id) => _doneKeys.contains('${_dateKey(day)}_${id.name}');

  Future<void> _toggleDone(DateTime day, PrayerId id) async {
    final key = '${_dateKey(day)}_${id.name}';
    setState(() {
      if (_doneKeys.contains(key)) {
        _doneKeys.remove(key);
      } else {
        _doneKeys.add(key);
      }
    });
    await _prefs?.setBool('prayer_done_$key', _doneKeys.contains(key));
  }

  Future<void> _toggleSound(PrayerId id) async {
    setState(() => _soundEnabled[id] = !(_soundEnabled[id] ?? true));
    await _prefs?.setBool('prayer_sound_${id.name}', _soundEnabled[id]!);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final heroDay = _service.compute(now: _now);
    final viewedDate = DateTime(_now.year, _now.month, _now.day).add(Duration(days: _dayOffset));
    final viewedDay = _service.compute(now: viewedDate.add(const Duration(hours: 12)));
    final isToday = _dayOffset == 0;
    final doneCount = viewedDay.five.where((s) => _isDone(viewedDate, s.id)).length;

    return Scaffold(
      backgroundColor: AppColor.cardColor.themeColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _Header(day: heroDay, now: _now),
              Transform.translate(
                offset: Offset(0, -18.h),
                child: _DateNavigator(
                  date: viewedDate,
                  onPrev: () => setState(() => _dayOffset -= 1),
                  onNext: () => setState(() => _dayOffset += 1),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: kFormPaddingAllLarge.w),
                child: Column(
                  children: [
                    for (final slot in viewedDay.all)
                      _PrayerRow(
                        slot: slot,
                        icon: _icons[slot.id]!,
                        isNext: isToday && slot.id == heroDay.next.id,
                        isDone: slot.id != PrayerId.sunrise && _isDone(viewedDate, slot.id),
                        soundEnabled: _soundEnabled[slot.id] ?? true,
                        onToggleDone: slot.id == PrayerId.sunrise ? null : () => _toggleDone(viewedDate, slot.id),
                        onToggleSound: slot.id == PrayerId.sunrise ? null : () => _toggleSound(slot.id),
                      ),
                  ],
                ),
              ),
              SizedBox(height: kFormPaddingAllLarge.h),
              _TodayProgress(done: doneCount, total: viewedDay.five.length),
              SizedBox(height: kFormPaddingAllLarge.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.day, required this.now});

  final PrayerDay day;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final remaining = day.remaining(now);
    final h = remaining.inHours.toString().padLeft(2, '0').toArabicNumbers;
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0').toArabicNumbers;
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0').toArabicNumbers;

    final isPm = day.next.time.hour >= 12;
    final hour12 = day.next.time.hour % 12 == 0 ? 12 : day.next.time.hour % 12;
    final clock = '$hour12:${day.next.time.minute.toString().padLeft(2, '0')}'.toArabicNumbers;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(kFormPaddingAllLarge.w, kFormPaddingAllNormal.h, kFormPaddingAllLarge.w, 48.h),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.themeColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(kFormRadius * 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => _showMethodSheet(context),
              ),
              Expanded(
                child: Text(
                  'مواقيت الصلاة',
                  textAlign: TextAlign.center,
                  style: const TextStyle().boldStyle().customColor(Colors.white).copyWith(fontSize: 16.sp),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
          SizedBox(height: kFormPaddingAllNormal.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: kFormPaddingAllLarge.w, vertical: kFormPaddingAllSmall.h),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.white70),
                SizedBox(width: 4.w),
                Text(day.locationName, style: const TextStyle().mediumStyle(fontSize: 12).customColor(Colors.white)),
              ],
            ),
          ),
          SizedBox(height: kFormPaddingAllLarge.h),
          Text('الصلاة القادمة', style: const TextStyle().mediumStyle(fontSize: 11).customColor(Colors.white70)),
          SizedBox(height: 4.h),
          Text(day.next.name, style: const TextStyle().boldStyle().customColor(AppColor.rateColor.themeColor).copyWith(fontSize: 26.sp)),
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(clock, style: const TextStyle().boldStyle().customColor(Colors.white).copyWith(fontSize: 22.sp)),
              SizedBox(width: 6.w),
              Text(isPm ? 'مساءً' : 'صباحًا', style: const TextStyle().mediumStyle(fontSize: 12).customColor(Colors.white70)),
            ],
          ),
          SizedBox(height: kFormPaddingAllLarge.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CountdownBox(value: h, label: 'ساعة'),
              SizedBox(width: kFormPaddingAllNormal.w),
              _CountdownBox(value: m, label: 'دقيقة'),
              SizedBox(width: kFormPaddingAllNormal.w),
              _CountdownBox(value: s, label: 'ثانية'),
            ],
          ),
        ],
      ),
    );
  }

  void _showMethodSheet(BuildContext context) {
    const methods = <String, String>{
      'egyptian': 'الهيئة المصرية العامة للمساحة',
      'ummAlQura': 'أم القرى',
      'muslimWorldLeague': 'رابطة العالم الإسلامي',
      'dubai': 'دبي',
      'qatar': 'قطر',
      'kuwait': 'الكويت',
      'karachi': 'كراتشي',
      'northAmerica': 'أمريكا الشمالية (ISNA)',
    };
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(vertical: kFormPaddingAllNormal.h),
              child: Text('طريقة حساب المواقيت', style: const TextStyle().semiBoldStyle(fontSize: 15).primaryTextColor()),
            ),
            for (final entry in methods.entries)
              ListTile(
                title: Text(entry.value, style: const TextStyle().mediumStyle(fontSize: 14).primaryTextColor()),
                onTap: () => Navigator.pop(sheetContext),
              ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _CountdownBox extends StatelessWidget {
  const _CountdownBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.r,
      padding: EdgeInsets.symmetric(vertical: kFormPaddingAllNormal.h),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(kFormRadius)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle().boldStyle().customColor(Colors.white).copyWith(fontSize: 18.sp)),
          SizedBox(height: 2.h),
          Text(label, style: const TextStyle().mediumStyle(fontSize: 10).customColor(Colors.white70)),
        ],
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({required this.date, required this.onPrev, required this.onNext});

  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    HijriCalendar.setLocal(context.locale.languageCode == 'ar' ? 'ar' : 'en');
    final hijri = HijriCalendar.fromDate(date);
    final gregorian = DateFormat('d MMMM yyyy', context.locale.languageCode).format(date);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: kFormPaddingAllLarge.w),
      padding: EdgeInsets.symmetric(horizontal: kFormPaddingAllNormal.w, vertical: kFormPaddingAllSmall.h),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor.themeColor,
        borderRadius: BorderRadius.circular(kFormRadius * 1.5),
        boxShadow: [BoxShadow(color: AppColor.shadowColor.themeColor.withValues(alpha: 0.15), blurRadius: 8)],
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev, color: AppColor.primaryColor.themeColor),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${hijri.toFormat("d MMMM yyyy")} هـ', style: const TextStyle().semiBoldStyle(fontSize: 13).primaryTextColor()),
                SizedBox(height: 2.h),
                Text(gregorian, style: const TextStyle().mediumStyle(fontSize: 11).customColor(AppColor.hintColor.themeColor)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext, color: AppColor.primaryColor.themeColor),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.slot,
    required this.icon,
    required this.isNext,
    required this.isDone,
    required this.soundEnabled,
    required this.onToggleDone,
    required this.onToggleSound,
  });

  final PrayerSlot slot;
  final IconData icon;
  final bool isNext;
  final bool isDone;
  final bool soundEnabled;
  final VoidCallback? onToggleDone;
  final VoidCallback? onToggleSound;

  bool get _isSunrise => slot.id == PrayerId.sunrise;

  @override
  Widget build(BuildContext context) {
    final hour12 = slot.time.hour % 12 == 0 ? 12 : slot.time.hour % 12;
    final isPm = slot.time.hour >= 12;
    final time = '$hour12:${slot.time.minute.toString().padLeft(2, '0')} ${isPm ? "م" : "ص"}'.toArabicNumbers;

    final Color fg = isNext
        ? Colors.white
        : (_isSunrise ? AppColor.hintColor.themeColor : AppColor.textColor.themeColor);

    return Container(
      margin: EdgeInsets.only(bottom: kFormPaddingAllNormal.h),
      padding: EdgeInsets.symmetric(horizontal: kFormPaddingAllNormal.w, vertical: kFormPaddingAllNormal.h),
      decoration: BoxDecoration(
        color: isNext ? AppColor.primaryColor.themeColor : AppColor.backgroundColor.themeColor,
        borderRadius: BorderRadius.circular(kFormRadius),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isSunrise ? Icons.notifications_off_outlined : (isDone ? Icons.check_circle : Icons.circle_outlined),
              color: _isSunrise ? AppColor.hintColor.themeColor : (isNext ? Colors.white : AppColor.primaryColor.themeColor),
            ),
            onPressed: onToggleDone,
          ),
          IconButton(
            icon: Icon(
              soundEnabled ? Icons.volume_up_outlined : Icons.volume_off_outlined,
              color: _isSunrise ? AppColor.hintColor.themeColor : (isNext ? Colors.white : AppColor.primaryColor.themeColor),
            ),
            onPressed: onToggleSound,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(slot.name, style: const TextStyle().semiBoldStyle(fontSize: 15).customColor(fg)),
                if (isNext) ...[
                  SizedBox(height: 2.h),
                  Text('الصلاة القادمة', style: const TextStyle().mediumStyle(fontSize: 10).customColor(AppColor.rateColor.themeColor)),
                ],
              ],
            ),
          ),
          Text(time, style: const TextStyle().semiBoldStyle(fontSize: 14).customColor(fg)),
          SizedBox(width: kFormPaddingAllNormal.w),
          Container(
            width: 36.r,
            height: 36.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isNext ? Colors.white24 : AppColor.primaryColorLight.themeColor,
              borderRadius: BorderRadius.circular(kFormRadiusSmall),
            ),
            child: Icon(icon, size: 18, color: isNext ? AppColor.rateColor.themeColor : AppColor.primaryColor.themeColor),
          ),
        ],
      ),
    );
  }
}

class _TodayProgress extends StatelessWidget {
  const _TodayProgress({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kFormPaddingAllLarge.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('صلوات اليوم', style: const TextStyle().semiBoldStyle(fontSize: 13).primaryTextColor()),
              Text('$done من $total'.toArabicNumbers, style: const TextStyle().mediumStyle(fontSize: 12).customColor(AppColor.hintColor.themeColor)),
            ],
          ),
          SizedBox(height: kFormPaddingAllNormal.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              final thumbX = (trackWidth - 28.r) * ratio;
              return SizedBox(
                height: 28.r,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(color: AppColor.grayScaleLiteColor.themeColor, borderRadius: BorderRadius.circular(3)),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(color: AppColor.primaryColor.themeColor, borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                    Positioned(
                      left: thumbX,
                      child: Container(
                        width: 28.r,
                        height: 28.r,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_downward, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
