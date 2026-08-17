import 'package:azkark/features/refactor/asmaallah/domain/entity/asma_allah_entity.dart';
import 'package:azkark/pages/search/components/not_found.dart';
import 'package:azkark/pages/search/components/search_field.dart';
import 'package:azkark/providers/settings_provider.dart';
import 'package:azkark/util/background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../asma_allah_list/widgets/asma_allah_list_item.dart';

/// Replaces the legacy `SearchForAsmaAllah` screen. Takes the already-loaded
/// [items] directly from [AsmaAllahListScreen] instead of re-deriving them
/// through a name-list + `indexOf` round trip: the legacy screen looked up
/// each suggestion by `allAmaAllah.indexOf(name)`, which breaks (returns the
/// wrong item, or -1) if two names are ever equal or the underlying list
/// changes shape between builds.
class AsmaAllahSearchScreen extends StatefulWidget {
  const AsmaAllahSearchScreen({super.key, required this.items});

  final List<AsmaAllahEntity> items;

  @override
  State<AsmaAllahSearchScreen> createState() => _AsmaAllahSearchScreenState();
}

class _AsmaAllahSearchScreenState extends State<AsmaAllahSearchScreen> {
  String _query = '';

  /// Ids whose description is currently expanded — keyed by id (not index)
  /// so it survives the filtered list reshuffling as the query changes.
  final Set<int> _expandedIds = {};

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Background(),
      Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: SearchField(
            title: '${tr('search_for_asmaallah')} . . . ',
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        body: _buildSuggestions(),
      ),
    ]);
  }

  Widget _buildSuggestions() {
    final suggestions = _query.isEmpty
        ? const <AsmaAllahEntity>[]
        : widget.items
            .where((item) => item.name.startsWith(_query))
            .toList();

    if (suggestions.isEmpty) return NotFound();

    final fontSize =
        (Provider.of<SettingsProvider>(context, listen: false)
                .getsettingField('font_size') as num)
            .toDouble();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: index == 0
              ? const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0)
              : index == suggestions.length - 1
                  ? const EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0)
                  : const EdgeInsets.only(left: 5.0, right: 5.0),
          child: AsmaAllahListItem(
            asmaAllah: suggestions[index],
            fontSize: fontSize,
            showDescription: _expandedIds.contains(suggestions[index].id),
            onTap: () => setState(() {
              final id = suggestions[index].id;
              if (!_expandedIds.remove(id)) _expandedIds.add(id);
            }),
          ),
        );
      },
    );
  }
}
