import 'package:azkark/util/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final ValueChanged<String> _onChanged;
  final String _title;

  @override
  _SearchFieldState createState() => _SearchFieldState();

  const SearchField({
    required ValueChanged<String> onChanged,
    required String title,
  })  : _onChanged = onChanged,
        _title = title;
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(bottom: 20.0, top: 20.0),
          padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
          width: size.width,
          decoration: BoxDecoration(
            color: teal[700],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        TextField(
          autofocus: true,
          controller: _textController,
          style: TextStyle(
            color: teal[50],
          ),
          textInputAction: TextInputAction.search,
          cursorColor: teal[200],
          decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.search,
                color: teal[50],
              ),
              suffixIcon: _textController.text.isNotEmpty
                  ? IconButton(
                      splashColor: teal[600],
                      highlightColor: teal[600],
                      onPressed: () {
                        print('You clicked on clear Text');
                        _textController.clear();
                        widget._onChanged(_textController.text);
                      },
                      padding: EdgeInsets.all(6),
                      tooltip: tr( 'delete'),
                      icon: Icon(
                        Icons.clear,
                        color: teal[50],
                        size: 20,
                      ),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              hintText: widget._title,
              hintStyle: TextStyle(color: Theme.of(context).cardColor, fontSize: 12)),
          onChanged: widget._onChanged,
        ),
      ],
    );
  }
}
