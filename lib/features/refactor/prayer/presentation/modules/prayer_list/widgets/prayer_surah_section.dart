import 'package:azkark/features/refactor/prayer/domain/entity/prayer_entity.dart';
import 'package:azkark/features/refactor/prayer/presentation/modules/prayer_list/widgets/prayer_aya_card.dart';
import 'package:azkark/util/colors.dart';
import 'package:flutter/material.dart';

/// One collapsible surah section: a header (the legacy `Surah` widget) plus,
/// when expanded, the list of verses for that surah (the legacy `AlAyat`
/// widget) — combined here since both were always used together (the
/// legacy `Prayer` widget just glued the two).
class PrayerSurahSection extends StatelessWidget {
  const PrayerSurahSection({
    super.key,
    required this.number,
    required this.surah,
    required this.ayat,
    required this.fontSize,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onToggleFavorite,
  });

  final int number;
  final String surah;
  final List<PrayerEntity> ayat;
  final double fontSize;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<PrayerEntity> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildHeader(context),
        if (expanded)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ayat.length,
              itemBuilder: (context, index) => PrayerAyaCard(
                prayer: ayat[index],
                fontSize: fontSize,
                onToggleFavorite: onToggleFavorite,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: teal[200],
          borderRadius: BorderRadius.circular(10),
          onTap: onToggleExpanded,
          child: Stack(
            children: <Widget>[
              Align(alignment: Alignment.topRight, child: _buildNumberField()),
              Padding(
                padding: const EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 15.0, right: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildNameField(),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: teal[700],
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

  Widget _buildNumberField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: teal[200],
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: Text(
        '$number',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: teal[700],
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        'سورة $surah',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: teal,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
