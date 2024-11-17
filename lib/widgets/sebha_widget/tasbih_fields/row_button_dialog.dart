import '../../../util/colors.dart';
import 'package:flutter/material.dart';

class RowButtons extends StatelessWidget {
  final String _titleFirst, _titleSecond;
  final GestureTapCallback? _onTapFirst, _onTapSecond;
  const RowButtons({
    required String titleFirst,
    required String titleSecond,
    required GestureTapCallback? onTapFirst,
    required GestureTapCallback? onTapSecond,
  })  : _titleFirst = titleFirst,
        _titleSecond = titleSecond,
        _onTapFirst = onTapFirst,
        _onTapSecond = onTapSecond;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildButton(
                text: _titleFirst,
                isClose: false,
                onTap: _onTapFirst,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildButton(
              text: _titleSecond,
              isClose: true,
              onTap: _onTapSecond,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButton({required String text,required GestureTapCallback? onTap,required bool isClose}) {
    return Material(
      color: isClose ? teal[200] : teal[600],
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        highlightColor: teal[500]!.withAlpha(100),
        splashColor: isClose ? teal[300] : teal[700],
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isClose ? teal[600] : teal[100],
            ),
          ),
        ),
      ),
    );
  }


}
