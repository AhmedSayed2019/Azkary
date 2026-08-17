import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';
import 'package:azkark/features/refactor/sebha/presentation/modules/add_edit_sebha/add_edit_sebha_dialog.dart';
import 'package:azkark/features/refactor/sebha/presentation/modules/sebha_list/sebha_list_view_model.dart';
import 'package:azkark/features/refactor/sebha/presentation/modules/sebha_list/widgets/sebha_item_menu_sheet.dart';
import 'package:azkark/features/refactor/sebha/presentation/modules/sebha_list/widgets/sebha_list_item.dart';
import 'package:azkark/providers.dart';
import 'package:azkark/util/background.dart';
import 'package:azkark/util/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Replaces the legacy `ItemsSebha` screen — the sebha (tasbih) list, backed
/// by [SebhaListViewModel] (a factory VM resolved from GetIt, not a
/// `ChangeNotifierProvider`).
class SebhaListScreen extends StatefulWidget {
  const SebhaListScreen({super.key});

  @override
  State<SebhaListScreen> createState() => _SebhaListScreenState();
}

class _SebhaListScreenState extends State<SebhaListScreen> {
  late final SebhaListViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<SebhaListViewModel>()..init();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _openAddDialog() async {
    final created = await showDialog<SebhaEntity>(
      context: context,
      builder: (_) => const AddEditSebhaDialog(),
    );
    if (created != null) _vm.upsertLocally(created);
  }

  void _openItemMenu(SebhaEntity sebha) {
    SebhaItemMenuSheet.show(
      context,
      sebha: sebha,
      onEdited: _vm.upsertLocally,
      onDelete: _vm.deleteSebha,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Background(),
      Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            tr('sebha_bar'),
            style: TextStyle(
              color: teal[50],
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            Container(
              margin: const EdgeInsets.all(8.0),
              child: IconButton(
                color: teal[50],
                highlightColor: teal[700],
                splashColor: teal[700],
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add),
                onPressed: _openAddDialog,
              ),
            ),
          ],
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
              itemCount: _vm.items.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: index == 0
                      ? const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0)
                      : index == _vm.items.length - 1
                          ? const EdgeInsets.only(
                              bottom: 8.0, left: 8.0, right: 8.0)
                          : const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: SebhaListItem(
                    sebha: _vm.items[index],
                    number: index + 1,
                    onToggleFavorite: _vm.toggleFavorite,
                    onOpenMenu: _openItemMenu,
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
