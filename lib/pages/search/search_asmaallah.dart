import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/asmaallah_provider.dart';
import '../../providers/settings_provider.dart';
import '../../util/background.dart';
import '../../widgets/asmaallah_widget/asmaallah.dart';
import 'components/not_found.dart';
import 'components/search_field.dart';

class SearchForAsmaAllah extends StatefulWidget {
  final List<String> _searchItems;

  @override
  _SearchForAsmaAllahState createState() => _SearchForAsmaAllahState();

  const SearchForAsmaAllah({
    required List<String> searchItems,
  }) : _searchItems = searchItems;
}

class _SearchForAsmaAllahState extends State<SearchForAsmaAllah> {
 late  List<String> _history;
 late  String query;

  @override
  void initState() {
    super.initState();
    query = '';
    _history = [];
    _history = [
      'الرحمن',
      'الرحيم',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Background(),
      Scaffold(
          appBar: AppBar(
            title: SearchField(
              title: '${tr( 'search_for_asmaallah')} . . . ',
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
            elevation: 0.0,
          ),
          body: buildSuggestions())
    ]);
  }

  Widget buildSuggestions() {
    final List<String> suggestions = query.isEmpty
        ? _history
        : widget._searchItems.where((word) => word.startsWith(query)).toList();

    return _WordSuggestionList(
      query: this.query,
      suggestions: suggestions,
    );
  }
}

class _WordSuggestionList extends StatelessWidget {
  final List<String> _suggestions;
  final String _query;

  const _WordSuggestionList({
    required List<String> suggestions,
    required String query,
  })  : _suggestions = suggestions,
        _query = query;

  @override
  Widget build(BuildContext context) {
    final asmaAllahProvider =
        Provider.of<AsmaAllahProvider>(context, listen: false);

    return _suggestions.length == 0
        ? NotFound()
        : ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: index == 0
                    ? const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0)
                    : index == _suggestions.length - 1
                        ? const EdgeInsets.only(
                            bottom: 5.0, left: 5.0, right: 5.0)
                        : const EdgeInsets.only(left: 5.0, right: 5.0),
                child: AsmaAllah(
                  asmaallah: asmaAllahProvider.getAsmaAllah(asmaAllahProvider
                      .allAmaAllah
                      .indexOf(_suggestions[index])),
                  fontSize:
                      Provider.of<SettingsProvider>(context, listen: false)
                          .getsettingField('font_size'),
                  showDescription: false,
                ),
              );
            });
  }


}
