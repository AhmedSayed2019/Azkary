part of '../../audio.dart';

/// خيارات مهلة الانتظار المتاحة بين تكرارات الآية الواحدة (بالثواني).
/// أول قيمة (0) تعني "بدون انتظار".
const List<int> _kAyahRepeatWaitOptions = [
  0,
  1,
  2,
  3,
  5,
  10,
  15,
  20,
  30,
  45,
  60,
];

/// خيارات عدد مرات التكرار (لكل آية أو للفقرة كاملة).
/// أول قيمة (0) تعني "بدون تكرار".
const List<int> _kAyahRepeatCountOptions = [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
];

/// يعرض BottomSheet "التكرار" الذي يتيح للمستخدم تحديد نطاق آيات (بداية/نهاية)
/// وإعدادات تكرار (تكرار كل آية، مهلة الانتظار، تكرار الفقرة بأكملها) ثم بدء
/// التشغيل التسلسلي وفق تلك الإعدادات، أو إلغاء تكرار جارٍ.
Future<void> showAyahRepeatSheet(
  BuildContext context, {
  required bool isDark,
  int? initialStartSurah,
  int? initialStartAya,
  int? initialEndSurah,
  int? initialEndAya,
  AyahAudioStyle? ayahAudioStyle,
}) async {
  await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.getBackgroundColor(isDark),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => AyahRepeatSheet(
      isDark: isDark,
      initialStartSurah: initialStartSurah ?? 1,
      initialStartAya: initialStartAya ?? 1,
      initialEndSurah: initialEndSurah,
      initialEndAya: initialEndAya,
      ayahAudioStyle: ayahAudioStyle,
    ),
  );
}

/// شاشة (BottomSheet) تحديد نطاق التكرار وإعداداته.
class AyahRepeatSheet extends StatefulWidget {
  const AyahRepeatSheet({
    super.key,
    required this.isDark,
    this.initialStartSurah = 1,
    this.initialStartAya = 1,
    this.initialEndSurah,
    this.initialEndAya,
    this.ayahAudioStyle,
  });

  final bool isDark;
  final int initialStartSurah;
  final int initialStartAya;
  final int? initialEndSurah;
  final int? initialEndAya;
  final AyahAudioStyle? ayahAudioStyle;

  @override
  State<AyahRepeatSheet> createState() => _AyahRepeatSheetState();
}

class _AyahRepeatSheetState extends State<AyahRepeatSheet> {
  late int _startSurah;
  late int _startAya;
  late int _endSurah;
  late int _endAya;

  int _repeatPerAyahIndex = 0;
  int _waitIndex = 0;
  int _repeatSectionIndex = 0;

  List<SurahModel> get _surahs => QuranCtrl.instance.surahs;

  @override
  void initState() {
    super.initState();
    _startSurah = widget.initialStartSurah;
    _startAya = widget.initialStartAya;
    _endSurah = widget.initialEndSurah ?? widget.initialStartSurah;
    _endAya = widget.initialEndAya ?? widget.initialStartAya;
  }

  int _ayahsCountOf(int surahNumber) {
    final surah = _surahs.firstWhereOrNull(
      (s) => s.surahNumber == surahNumber,
    );
    return surah?.ayahs.length ?? 1;
  }

  String _surahLabel(int surahNumber) {
    final surah = _surahs.firstWhereOrNull(
      (s) => s.surahNumber == surahNumber,
    );
    return '$surahNumber. ${surah?.arabicName ?? ''}';
  }

  /// Opens a searchable surah picker instead of cycling one-by-one through
  /// all 114 surahs.
  Future<void> _pickSurah({
    required int currentSurah,
    required ValueChanged<int> onSelected,
  }) async {
    final selected = await showModalBottomSheet<int>(
      context: this.context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.getBackgroundColor(widget.isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SurahPickerSheet(
        isDark: widget.isDark,
        surahs: _surahs,
        currentSurah: currentSurah,
      ),
    );
    if (selected != null) onSelected(selected);
  }

  void _pickStartSurah() {
    _pickSurah(
      currentSurah: _startSurah,
      onSelected: (surah) {
        setState(() {
          _startSurah = surah;
          final maxAya = _ayahsCountOf(_startSurah);
          if (_startAya > maxAya) _startAya = 1;
        });
      },
    );
  }

  void _pickEndSurah() {
    _pickSurah(
      currentSurah: _endSurah,
      onSelected: (surah) {
        setState(() {
          _endSurah = surah;
          final maxAya = _ayahsCountOf(_endSurah);
          if (_endAya > maxAya) _endAya = maxAya;
        });
      },
    );
  }

  void _incrementStartAya() {
    setState(() {
      final maxAya = _ayahsCountOf(_startSurah);
      _startAya = _startAya >= maxAya ? maxAya : _startAya + 1;
    });
  }

  void _decrementStartAya() {
    setState(() {
      _startAya = _startAya <= 1 ? 1 : _startAya - 1;
    });
  }

  void _incrementEndAya() {
    setState(() {
      final maxAya = _ayahsCountOf(_endSurah);
      _endAya = _endAya >= maxAya ? maxAya : _endAya + 1;
    });
  }

  void _decrementEndAya() {
    setState(() {
      _endAya = _endAya <= 1 ? 1 : _endAya - 1;
    });
  }

  void _incrementRepeatPerAyah() {
    setState(() {
      _repeatPerAyahIndex = (_repeatPerAyahIndex + 1)
          .clamp(0, _kAyahRepeatCountOptions.length - 1);
    });
  }

  void _decrementRepeatPerAyah() {
    setState(() {
      _repeatPerAyahIndex = (_repeatPerAyahIndex - 1).clamp(0, _kAyahRepeatCountOptions.length - 1);
    });
  }

  void _incrementWait() {
    setState(() {
      _waitIndex =
          (_waitIndex + 1).clamp(0, _kAyahRepeatWaitOptions.length - 1);
    });
  }

  void _decrementWait() {
    setState(() {
      _waitIndex =
          (_waitIndex - 1).clamp(0, _kAyahRepeatWaitOptions.length - 1);
    });
  }

  void _incrementRepeatSection() {
    setState(() {
      _repeatSectionIndex = (_repeatSectionIndex + 1)
          .clamp(0, _kAyahRepeatCountOptions.length - 1);
    });
  }

  void _decrementRepeatSection() {
    setState(() {
      _repeatSectionIndex = (_repeatSectionIndex - 1)
          .clamp(0, _kAyahRepeatCountOptions.length - 1);
    });
  }

  String _waitLabel(int seconds) =>
      seconds == 0 ? 'بدون انتظار' : '$seconds ثانية';

  String _repeatCountLabel(int count) =>
      count == 0 ? 'بدون تكرار' : '$count مرات';

  Future<void> _onCancelRepeatTap() async {
    await AudioCtrl.instance.cancelAyahRangeRepeat();
    if (mounted) Navigator.of(this.context).pop();
  }

  Future<void> _onStartTap() async {
    final BuildContext buildContext = this.context;
    final audioCtrl = AudioCtrl.instance;
    final navigator = Navigator.of(buildContext);
    await audioCtrl.startAyahRangeRepeat(
      buildContext,
      startSurah: _startSurah,
      startAya: _startAya,
      endSurah: _endSurah,
      endAya: _endAya,
      repeatPerAyah: _kAyahRepeatCountOptions[_repeatPerAyahIndex],
      waitSeconds: _kAyahRepeatWaitOptions[_waitIndex],
      repeatSection: _kAyahRepeatCountOptions[_repeatSectionIndex],
      ayahAudioStyle: widget.ayahAudioStyle,
      isDarkMode: widget.isDark,
    );
    if (navigator.mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextColor(widget.isDark);
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(textColor: textColor),
                const SizedBox(height: 4),
                _CancelRepeatLink(
                  color: primary,
                  onTap: _onCancelRepeatTap,
                ),
                const SizedBox(height: 16),
                _SectionTitle(text: 'تحديد البدء', color: textColor),
                const SizedBox(height: 8),
                _StepperRow(
                  label: 'السورة',
                  value: _surahLabel(_startSurah),
                  textColor: textColor,
                  accentColor: primary,
                  onTap: _pickStartSurah,
                  icon: Icons.expand_more,
                ),
                const SizedBox(height: 8),
                _PlusMinusRow(
                  label: 'الآية',
                  value: '$_startAya',
                  textColor: textColor,
                  accentColor: primary,
                  onIncrement: _incrementStartAya,
                  onDecrement: _decrementStartAya,
                ),
                const SizedBox(height: 20),
                _SectionTitle(text: 'تحديد الانتهاء', color: textColor),
                const SizedBox(height: 8),
                _StepperRow(
                  label: 'السورة',
                  value: _surahLabel(_endSurah),
                  textColor: textColor,
                  accentColor: primary,
                  onTap: _pickEndSurah,
                  icon: Icons.expand_more,
                ),
                const SizedBox(height: 8),
                _PlusMinusRow(
                  label: 'الآية',
                  value: '$_endAya',
                  textColor: textColor,
                  accentColor: primary,
                  onIncrement: _incrementEndAya,
                  onDecrement: _decrementEndAya,
                ),
                const SizedBox(height: 20),
                _SectionTitle(text: 'التكرار', color: textColor),
                const SizedBox(height: 8),
                _PlusMinusRow(
                  label: 'التكرار للآية',
                  value: _repeatCountLabel(
                      _kAyahRepeatCountOptions[_repeatPerAyahIndex]),
                  textColor: textColor,
                  accentColor: primary,
                  onIncrement: _incrementRepeatPerAyah,
                  onDecrement: _decrementRepeatPerAyah,
                ),
                const SizedBox(height: 8),
                _PlusMinusRow(
                  label: 'الانتظار',
                  value: _waitLabel(_kAyahRepeatWaitOptions[_waitIndex]),
                  textColor: textColor,
                  accentColor: primary,
                  onIncrement: _incrementWait,
                  onDecrement: _decrementWait,
                ),
                const SizedBox(height: 8),
                _PlusMinusRow(
                  label: 'التكرار للفقرة',
                  value: _repeatCountLabel(
                      _kAyahRepeatCountOptions[_repeatSectionIndex]),
                  textColor: textColor,
                  accentColor: primary,
                  onIncrement: _incrementRepeatSection,
                  onDecrement: _decrementRepeatSection,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _onStartTap,
                    child: Text(
                      'بدء',
                      style: QuranLibrary().cairoStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18),
        ),
        Expanded(
          child: Text(
            'التكرار',
            textAlign: TextAlign.center,
            style: QuranLibrary().cairoStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _CancelRepeatLink extends StatelessWidget {
  const _CancelRepeatLink({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        child: Text(
          'إلغاء التكرار',
          style: QuranLibrary().cairoStyle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: QuranLibrary().cairoStyle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
      ),
    );
  }
}

/// صف "منتقٍ" (stepper) يعرض تسمية القيمة، والقيمة الحالية، وزر [+] دائري
/// عند النقر عليه يدور (cycle) عبر القيم المتاحة. يتّبع نمط الأيقونة
/// الدائرية البسيطة المستخدم في بقية عناصر تحكم الصوت بالمكتبة.
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.accentColor,
    required this.onTap,
    this.icon = Icons.add,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color accentColor;
  final VoidCallback onTap;

  /// Icon shown in the small circular button. Defaults to [Icons.add]
  /// (cycle-by-one); pass [Icons.expand_more] for rows that open a picker.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accentColor.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            // ترتيب العناصر ثابت بصريًا (الزر والتسمية في أقصى اليسار، القيمة
            // في أقصى اليمين) بغض النظر عن اتجاه اللغة، مطابقةً لتصميم الشاشة.
            textDirection: TextDirection.ltr,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: QuranLibrary().cairoStyle.copyWith(
                      fontSize: 14,
                      color: textColor,
                    ),
              ),
              const Spacer(),
              Text(
                value,
                style: QuranLibrary().cairoStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row with distinct [+]/[-] circular buttons flanking the value, used for
/// every numeric stepper (ayah number, repeat counts, wait duration) so the
/// user can move in either direction instead of only cycling forward.
class _PlusMinusRow extends StatelessWidget {
  const _PlusMinusRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.accentColor,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color accentColor;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accentColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        // ترتيب العناصر ثابت بصريًا (زرا +/- في أقصى اليسار، التسمية بعدهما،
        // القيمة في أقصى اليمين) بغض النظر عن اتجاه اللغة، مطابقةً لتصميم
        // الشاشة.
        textDirection: TextDirection.ltr,
        children: [
          _circleButton(Icons.remove, onDecrement),
          const SizedBox(width: 8),
          _circleButton(Icons.add, onIncrement),
          const SizedBox(width: 10),
          Text(
            label,
            style: QuranLibrary().cairoStyle.copyWith(
                  fontSize: 14,
                  color: textColor,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: QuranLibrary().cairoStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet with a search field to filter the 114 surahs by name or
/// number, and a scrollable list to tap-select one. Pops with the selected
/// surah number, or `null` if dismissed without a selection.
class _SurahPickerSheet extends StatefulWidget {
  const _SurahPickerSheet({
    required this.isDark,
    required this.surahs,
    required this.currentSurah,
  });

  final bool isDark;
  final List<SurahModel> surahs;
  final int currentSurah;

  @override
  State<_SurahPickerSheet> createState() => _SurahPickerSheetState();
}

class _SurahPickerSheetState extends State<_SurahPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<SurahModel> _filtered = widget.surahs;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    setState(() {
      _filtered = query.isEmpty
          ? widget.surahs
          : widget.surahs
              .where((s) =>
                  s.arabicName.contains(query) ||
                  s.surahNumber.toString() == query)
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextColor(widget.isDark);
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'اختر السورة',
                  style: QuranLibrary().cairoStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchCtrl,
                  autofocus: false,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم أو رقم السورة...',
                    hintStyle:
                        TextStyle(color: textColor.withValues(alpha: 0.5)),
                    prefixIcon:
                        Icon(Icons.search, color: textColor.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: primary.withValues(alpha: 0.06),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text('لا توجد نتائج',
                              style: TextStyle(color: textColor)),
                        )
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final surah = _filtered[index];
                            final isCurrent =
                                surah.surahNumber == widget.currentSurah;
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () =>
                                    Navigator.of(context).pop(surah.surahNumber),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  margin: const EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? primary.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor:
                                            primary.withValues(alpha: 0.12),
                                        child: Text(
                                          '${surah.surahNumber}',
                                          style: TextStyle(
                                              color: primary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          surah.arabicName,
                                          style: QuranLibrary().cairoStyle.copyWith(
                                                fontSize: 15,
                                                color: textColor,
                                                fontWeight: isCurrent
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                        ),
                                      ),
                                      if (isCurrent)
                                        Icon(Icons.check,
                                            color: primary, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
