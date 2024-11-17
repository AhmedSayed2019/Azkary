import '../../util/helpers.dart';
import '../../providers/categories_provider.dart';
import '../../widgets/categories_widget/category.dart';
import 'package:provider/provider.dart';
import '../../util/background.dart';
import 'package:flutter/material.dart';
import 'components/not_found.dart';
import 'components/search_field.dart';

class SearchForZekr extends StatefulWidget {
  @override
  _SearchForZekrState createState() => _SearchForZekrState();
}

class _SearchForZekrState extends State<SearchForZekr> {
 late List<String> _history, searchItems;
 late String query;

  @override
  void initState() {
    super.initState();
    query = '';
    searchItems = Provider.of<CategoriesProvider>(context, listen: false)
        .allCategoriesName;
    _history = [];
    _history = [
      'أذكار الاستيقاظ من النوم',
      'أذكار النوم',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Background(),
      Scaffold(
          appBar: AppBar(
            title: Hero(
              tag: 'search',
              child: SearchField(
                title: '${translate(context, 'search_for_zekr')} . . . ',
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
              ),
            ),
            elevation: 0.0,
          ),
          body: buildSuggestions())
    ]);
  }

  Widget buildSuggestions() {
    final List<String> suggestions = query.isEmpty
        ? _history
        : searchItems.where((word) => word.contains(query)).toList();

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
    final categoriesProvider =
        Provider.of<CategoriesProvider>(context, listen: false);

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
                child: Category(
                  categoriesProvider.getCategory(categoriesProvider
                      .allCategoriesName
                      .indexOf(_suggestions[index])),
                ),
              );
            });
  }


}
