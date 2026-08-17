import 'package:azkark/features/refactor/prayer/presentation/modules/prayer_list/prayer_list_view_model.dart';
import 'package:azkark/features/refactor/prayer/presentation/modules/prayer_list/widgets/prayer_surah_section.dart';
import 'package:azkark/providers.dart';
import 'package:azkark/providers/settings_provider.dart';
import 'package:azkark/util/background.dart';
import 'package:azkark/util/colors.dart';
import 'package:azkark/widgets/slider_font_size/button_font_size.dart';
import 'package:azkark/widgets/slider_font_size/slider_font_size.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

enum _PrayerPopupMenu { showAllAyat }

/// Replaces the legacy `ViewPrayer` screen — the prayer-guide (verses
/// grouped by surah) list, backed by [PrayerListViewModel] (a factory VM
/// resolved from GetIt, not a `ChangeNotifierProvider`).
class PrayerListScreen extends StatefulWidget {
  const PrayerListScreen({super.key});

  @override
  State<PrayerListScreen> createState() => _PrayerListScreenState();
}

class _PrayerListScreenState extends State<PrayerListScreen> {
  late final PrayerListViewModel _vm;

  bool _showSliderFont = false;
  bool _showAllAyat = false;
  final Set<String> _expandedSurahs = {};
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize = Provider.of<SettingsProvider>(context, listen: false)
        .getsettingField('font_size');
    _vm = getIt<PrayerListViewModel>()..init();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  void _toggleSurah(String surah) {
    setState(() {
      if (_expandedSurahs.contains(surah)) {
        _expandedSurahs.remove(surah);
      } else {
        _expandedSurahs.add(surah);
      }
    });
  }

  void _toggleShowAllAyat() {
    setState(() {
      _showAllAyat = !_showAllAyat;
      _expandedSurahs
        ..clear()
        ..addAll(_showAllAyat ? _vm.surahNames : const <String>[]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Background(),
      Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            tr('prayer_bar'),
            style: TextStyle(
              color: teal[50],
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            ButtonFontSize(
              showSider: _showSliderFont,
              onTap: () => setState(() => _showSliderFont = !_showSliderFont),
            ),
            _buildPopUpMenu(),
          ],
        ),
        body: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            return Stack(
              children: <Widget>[
                _buildBody(),
                if (_showSliderFont)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SliderFontSize(
                        fontSize: _fontSize,
                        min: 14,
                        max: 30,
                        onChanged: (value) =>
                            setState(() => _fontSize = value),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildBody() {
    if (_vm.isLoading && _vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_vm.error != null && _vm.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_vm.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _vm.retry,
                child: Text(tr('tryAgain')),
              ),
            ],
          ),
        ),
      );
    }

    final surahNames = _vm.surahNames;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: surahNames.length,
      itemBuilder: (context, index) {
        final surah = surahNames[index];
        return Padding(
          padding: index == 0
              ? const EdgeInsets.only(top: 8.0, bottom: 4.0, left: 8.0, right: 8.0)
              : index == surahNames.length - 1
                  ? const EdgeInsets.only(top: 4.0, bottom: 8.0, left: 8.0, right: 8.0)
                  : const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
          child: PrayerSurahSection(
            number: index + 1,
            surah: surah,
            ayat: _vm.ayatOfSurah(surah),
            fontSize: _fontSize,
            expanded: _expandedSurahs.contains(surah),
            onToggleExpanded: () => _toggleSurah(surah),
            onToggleFavorite: (entity) => _vm.toggleFavorite(entity),
          ),
        );
      },
    );
  }

  Widget _buildPopUpMenu() {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: PopupMenuButton<_PrayerPopupMenu>(
        offset: const Offset(0, 50),
        tooltip: tr('popup_menu'),
        onSelected: (result) {
          switch (result) {
            case _PrayerPopupMenu.showAllAyat:
              _toggleShowAllAyat();
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem<_PrayerPopupMenu>(
              value: _PrayerPopupMenu.showAllAyat,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 150,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _showAllAyat
                          ? tr('popup_menu_aya_true')
                          : tr('popup_menu_aya_false'),
                      style: TextStyle(
                        color: teal[900],
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  FaIcon(
                    _showAllAyat
                        ? FontAwesomeIcons.toggleOn
                        : FontAwesomeIcons.toggleOff,
                    color: _showAllAyat ? teal[500] : teal,
                    size: 20,
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }
}
