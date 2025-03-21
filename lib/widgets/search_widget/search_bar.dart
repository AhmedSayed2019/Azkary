import 'package:flutter/material.dart';

import '../../util/colors.dart';

class SearchBar extends StatelessWidget {
  final String _title;
  final  GestureTapCallback? _onTap;

  const SearchBar({
    required String title,
    required GestureTapCallback? onTap,
  })  : _title = title,
        _onTap = onTap;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: _onTap,
      child: Container(
        width: size.width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: teal[200],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          height: size.height * 0.055,
          decoration: BoxDecoration(
            color: teal[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.search,
                color: teal[50],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  _title,
                  style: TextStyle(
                    color: teal[300],
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
