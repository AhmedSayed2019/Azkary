import 'package:azkark/features/refactor/asmaallah/presentation/modules/asma_allah_list/asma_allah_list_view_model.dart';
import 'package:azkark/features/refactor/asmaallah/presentation/modules/asma_allah_list/widgets/asma_allah_app_bar.dart';
import 'package:azkark/features/refactor/asmaallah/presentation/modules/asma_allah_list/widgets/asma_allah_list_item.dart';
import 'package:azkark/features/refactor/asmaallah/presentation/modules/asma_allah_search/asma_allah_search_screen.dart';
import 'package:azkark/providers.dart';
import 'package:azkark/providers/settings_provider.dart';
import 'package:azkark/util/background.dart';
import 'package:azkark/util/navigate_between_pages/fade_route.dart';
import 'package:azkark/widgets/search_widget/search_bar.dart';
import 'package:azkark/widgets/slider_font_size/slider_font_size.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Replaces the legacy `ViewAsmaAllah` screen — the 99-names-of-Allah list,
/// backed by [AsmaAllahListViewModel] (a factory VM resolved from GetIt,
/// not a `ChangeNotifierProvider`).
class AsmaAllahListScreen extends StatefulWidget {
  const AsmaAllahListScreen({super.key});

  @override
  State<AsmaAllahListScreen> createState() => _AsmaAllahListScreenState();
}

class _AsmaAllahListScreenState extends State<AsmaAllahListScreen> {
  late final AsmaAllahListViewModel _vm;
  bool _showSliderFont = false;

  @override
  void initState() {
    super.initState();
    _vm = getIt<AsmaAllahListViewModel>()..init();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  void _openSearch() {
    Navigator.push(
      context,
      FadeRoute(page: AsmaAllahSearchScreen(items: _vm.items)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // `listen: false` on purpose — this is a one-shot read of the current
    // font size, same as the legacy screen; the slider below owns further
    // changes locally rather than round-tripping through the provider.
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return Stack(children: <Widget>[
      Background(),
      ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          return _AsmaAllahListBody(
            vm: _vm,
            size: size,
            settingsProvider: settingsProvider,
            showSliderFont: _showSliderFont,
            onToggleSliderFont: () =>
                setState(() => _showSliderFont = !_showSliderFont),
            onOpenSearch: _openSearch,
          );
        },
      ),
    ]);
  }
}

class _AsmaAllahListBody extends StatefulWidget {
  const _AsmaAllahListBody({
    required this.vm,
    required this.size,
    required this.settingsProvider,
    required this.showSliderFont,
    required this.onToggleSliderFont,
    required this.onOpenSearch,
  });

  final AsmaAllahListViewModel vm;
  final Size size;
  final SettingsProvider settingsProvider;
  final bool showSliderFont;
  final VoidCallback onToggleSliderFont;
  final VoidCallback onOpenSearch;

  @override
  State<_AsmaAllahListBody> createState() => _AsmaAllahListBodyState();
}

class _AsmaAllahListBodyState extends State<_AsmaAllahListBody> {
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize = (widget.settingsProvider.getsettingField('font_size') as num)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return Scaffold(
      appBar: AsmaAllahAppBar(
        description: vm.showAllDescription,
        sliderFont: widget.showSliderFont,
        onTapDescription: vm.toggleAllDescriptions,
        onTapFontButton: widget.onToggleSliderFont,
      ),
      body: Stack(
        children: <Widget>[
          SizedBox(
            width: widget.size.width,
            height: widget.size.height,
            child: Column(
              children: <Widget>[
                CustomSearchBar(
                  title: '${tr('search_for_asmaallah')} . . . ',
                  onTap: widget.onOpenSearch,
                ),
                Expanded(child: _buildList(vm)),
              ],
            ),
          ),
          if (widget.showSliderFont)
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SliderFontSize(
                  fontSize: _fontSize,
                  min: 14,
                  max: 30,
                  onChanged: (value) => setState(() => _fontSize = value),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(AsmaAllahListViewModel vm) {
    if (vm.isLoading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null && vm.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(vm.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: vm.retry,
                child: Text(tr('tryAgain')),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: vm.items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: index == 0
              ? const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0)
              : index == vm.items.length - 1
                  ? const EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0)
                  : const EdgeInsets.only(left: 5.0, right: 5.0),
          child: AsmaAllahListItem(
            asmaAllah: vm.items[index],
            fontSize: _fontSize,
            showDescription: vm.showDescriptionAt(index),
            onTap: () => vm.toggleDescriptionAt(index),
          ),
        );
      },
    );
  }
}
