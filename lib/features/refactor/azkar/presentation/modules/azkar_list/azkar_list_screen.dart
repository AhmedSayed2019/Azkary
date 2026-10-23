import 'package:azkark/core/res/resources.dart';
import 'package:azkark/features/refactor/azkar/presentation/modules/azkar_list/azkar_list_view_model.dart';
import 'package:azkark/features/refactor/azkar/presentation/modules/azkar_list/widgets/azkar_app_bar.dart';
import 'package:azkark/features/refactor/azkar/presentation/modules/azkar_list/widgets/zekr_card.dart';
import 'package:azkark/features/refactor/categories/domain/entity/category_entity.dart';
import 'package:azkark/providers.dart';
import 'package:azkark/util/background.dart';
import 'package:azkark/widgets/slider_font_size/slider_font_size.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Replaces the legacy `ViewAzkar` screen — the reading screen for one
/// category's azkar, backed by [AzkarListViewModel] (a factory VM resolved
/// from GetIt, not a `ChangeNotifierProvider`).
///
/// The category arrives as a constructor parameter instead of being fished
/// out of a global provider: the legacy screen read `AzkarProvider` for the
/// first zekr, then looked its category up by *list position*, which silently
/// resolved to the wrong row whenever ids and positions disagreed.
class AzkarListScreen extends StatefulWidget {
  const AzkarListScreen({super.key, required this.category});

  final CategoryEntity category;

  @override
  State<AzkarListScreen> createState() => _AzkarListScreenState();
}

class _AzkarListScreenState extends State<AzkarListScreen> {
  late final AzkarListViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<AzkarListViewModel>()
      ..configure(widget.category)
      ..init();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Background(),
      Scaffold(
        body: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            return Stack(
              children: <Widget>[
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: <Widget>[
                    AzkarAppBar(
                      title: _vm.title,
                      favorite: _vm.favorite,
                      counter: _vm.counterEnabled,
                      diacritics: _vm.diacriticsEnabled,
                      sanad: _vm.sanadEnabled,
                      sliderFont: _vm.showFontSlider,
                      onTapFavorite: _vm.toggleFavorite,
                      onTapCounter: _vm.toggleCounter,
                      onTapDiacritics: _vm.toggleDiacritics,
                      onTapSanad: _vm.toggleSanad,
                      onTapRefresh: _vm.resetAllCounters,
                      onTapFontButton: _vm.toggleFontSlider,
                    ),
                    _AzkarBody(vm: _vm),
                  ],
                ),
                if (_vm.showFontSlider)
                  Padding(
                    padding: const EdgeInsets.only(bottom: kScreenPaddingNormal),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SliderFontSize(
                        fontSize: _vm.fontSize,
                        min: 14,
                        max: 30,
                        onChanged: _vm.setFontSize,
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
}

/// The four states of the list — loading / error / empty / data — as slivers
/// so they sit under the same collapsing header.
class _AzkarBody extends StatelessWidget {
  const _AzkarBody({required this.vm});

  final AzkarListViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading && vm.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.error != null && vm.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _ErrorRetryView(message: vm.error!, onRetry: vm.retry),
      );
    }

    if (vm.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyView(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, int index) {
          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? kFormPaddingAllLarge : kFormPaddingAllSmall + 2,
              bottom: index == vm.items.length - 1
                  ? kFormPaddingAllLarge
                  : kFormPaddingAllSmall + 2,
              left: kFormPaddingAllLarge,
              right: kFormPaddingAllLarge,
            ),
            child: ZekrCard(
              zekr: vm.items[index],
              number: index + 1,
              total: vm.items.length,
              counter: vm.counterAt(index),
              counterEnabled: vm.counterEnabled,
              diacriticsEnabled: vm.diacriticsEnabled,
              showSanad: vm.sanadVisibleAt(index),
              fontSize: vm.fontSize,
              fontFamily: vm.fontFamily,
              onTap: () => vm.increment(index),
              onRefresh: () => vm.resetCounterAt(index),
              onToggleSanad: () => vm.toggleSanadAt(index),
            ),
          );
        },
        childCount: vm.items.length,
      ),
    );
  }
}

class _ErrorRetryView extends StatelessWidget {
  const _ErrorRetryView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kScreenPaddingNormal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr('error_occured'),
              textAlign: TextAlign.center,
              style: const TextStyle().semiBoldStyle(fontSize: 16).primaryTextColor(),
            ),
            const SizedBox(height: kFormPaddingAllNormal),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle()
                  .regularStyle(fontSize: 12)
                  .customColor(AppColor.textSecondaryDark.themeColor),
            ),
            const SizedBox(height: kFormPaddingAllLarge),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(tr('tryAgain')),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kScreenPaddingNormal),
        child: Text(
          tr('azkar_empty'),
          textAlign: TextAlign.center,
          style: const TextStyle()
              .semiBoldStyle(fontSize: 16)
              .customColor(AppColor.textSecondaryDark.themeColor),
        ),
      ),
    );
  }
}
