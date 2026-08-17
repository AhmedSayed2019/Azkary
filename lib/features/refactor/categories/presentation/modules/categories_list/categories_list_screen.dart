import 'package:azkark/features/azkar/view_azkar.dart';
import 'package:azkark/features/refactor/categories/domain/entity/category_entity.dart';
import 'package:azkark/features/refactor/categories/presentation/modules/categories_list/categories_list_view_model.dart';
import 'package:azkark/features/refactor/categories/presentation/modules/categories_list/widgets/category_list_item.dart';
import 'package:azkark/providers.dart';
import 'package:azkark/providers/azkar_provider.dart';
import 'package:azkark/util/background.dart';
import 'package:azkark/util/colors.dart';
import 'package:azkark/util/navigate_between_pages/fade_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Replaces the legacy `ViewAllCategories` screen — the "all categories"
/// list, backed by [CategoriesListViewModel] (a factory VM resolved from
/// GetIt, not a `ChangeNotifierProvider`).
class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  late final CategoriesListViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<CategoriesListViewModel>()..init();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _openCategory(CategoryEntity category) async {
    final azkarProvider = Provider.of<AzkarProvider>(context, listen: false);
    await azkarProvider.initialAllAzkar(category.azkarIndex);
    // Guard against the widget being unmounted while awaiting the DB read
    // above (the legacy `Category` widget navigated unconditionally after
    // the same await, which could push onto a disposed context).
    if (!mounted) return;
    Navigator.push(context, FadeRoute(page: const ViewAzkar()));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Background(),
      Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            tr('all_categories'),
            style: TextStyle(
              color: teal[50],
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
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
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _vm.items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: index == 0
                      ? const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0)
                      : index == _vm.items.length - 1
                          ? const EdgeInsets.only(
                              bottom: 5.0, left: 5.0, right: 5.0)
                          : const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: CategoryListItem(
                    category: _vm.items[index],
                    onTap: () => _openCategory(_vm.items[index]),
                    onToggleFavorite: _vm.toggleFavorite,
                  ),
                );
              },
            );
          },
        ),
      ),
    ]);
  }
}
