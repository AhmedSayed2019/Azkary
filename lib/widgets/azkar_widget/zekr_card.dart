import 'package:azkark/util/helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/zekr_model.dart';
import '../../providers/azkar_provider.dart';
import '../../providers/settings_provider.dart';
import '../../util/colors.dart';

class Zekr extends StatefulWidget {
  final ZekrModel zekr;
  final int numberZekr, counter;
  final bool isCounterOpen, isDiacriticsOpen, showSanad;
  final GestureTapCallback onTap, onRefresh, onSanad;
  final double fontSize;

  @override
  _ZekrState createState() => _ZekrState();

  const Zekr({
    required this.zekr,
    required this.numberZekr,
    required this.counter,
    required this.isCounterOpen,
    required this.isDiacriticsOpen,
    required this.showSanad,
    required this.onTap,
    required this.onRefresh,
    required this.onSanad,
    required this.fontSize,
  });
}

class _ZekrState extends State<Zekr> {
  late String _fontType;

  @override
  void initState() {
    super.initState();
    _fontType = Provider.of<SettingsProvider>(context, listen: false)
        .getsettingField('font_family')
        .toString();
  }

  bool get isFinish => widget.counter == widget.zekr.counterNumber;

  String get text => widget.isDiacriticsOpen
      ? '${widget.zekr.textWithDiacritics}\n***********\nالسند :\n${widget.zekr.sanad}'
      : widget.zekr.textWithoutDiacritics +
          '\n***********\nالسند :\n' +
          widget.zekr.sanad;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: isFinish ? teal[200] : teal[300],
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: teal[200],
        borderRadius: BorderRadius.circular(10),
        onTap: widget.isCounterOpen ? widget.onTap : null,
        onLongPress: () => copyText(context, text),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              _buildRefreshButton(size),
              _buildTextZekr(size),
              _buildNumberRepetitions(size),
              _buildBottomWidget(size),
              if (widget.showSanad) _buildTextSanad(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(Size size) {
    if (isFinish) {
      return Align(
        alignment: Alignment.topLeft,
        child: InkWell(
          onTap: widget.onRefresh,
          child: Icon(
            Icons.refresh,
            color: isFinish ? teal[400] : teal[600],
          ),
        ),
      );
    } else {
      return const SizedBox(
        height: 24,
      );
    }
  }

  Widget _buildTextZekr(Size size) {
    return Text(
      widget.isDiacriticsOpen
          ? widget.zekr.textWithDiacritics
          : widget.zekr.textWithoutDiacritics,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isFinish ? teal[400] : teal[900],
        fontFamily: _fontType,
        fontSize: widget.fontSize,
      ),
    );
  }

  Widget _buildBottomWidget(Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Align(alignment: Alignment.centerRight, child: _buildNumberOfAzkar()),
          if (widget.counter != 0)
            Align(alignment: Alignment.center, child: _buildCounter()),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildButton(
                  icon: Icons.content_copy,
                  onTap: () => copyText(context, text),
                ),
                _buildButton(
                  icon: widget.showSanad ? Icons.info : Icons.info_outline,
                  onTap: widget.onSanad,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required GestureTapCallback onTap,required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
        onTap: onTap,
        child: Icon(
          icon,
          color: isFinish ? teal[400] : teal[600],
        ),
      ),
    );
  }

  Widget _buildNumberOfAzkar() {
    return Text(
      'الذكر ${widget.numberZekr} من ${Provider.of<AzkarProvider>(context, listen: false).length}',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: teal[400],
        fontFamily: _fontType,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTextSanad(Size size) {
    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      margin: const EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        color: isFinish ? teal[100] : teal[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        widget.zekr.sanad,
        style: TextStyle(
          color: isFinish ? teal[400] : teal[600],
          fontFamily: _fontType,
          fontSize: widget.fontSize - 2,
        ),
      ),
    );
  }

  Widget _buildCounter() {
    return Container(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 15.0, right: 15.0),
      decoration: BoxDecoration(
        color: isFinish ? teal[300] : teal[500],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '${widget.counter} / ${widget.zekr.counterNumber}',
        style: TextStyle(
          color: isFinish ? teal[400] : teal[100],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildNumberRepetitions(Size size) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0, bottom: 5.0, left: 15.0, right: 15.0),
      child: Text(
        widget.zekr.counterText ?? tr( 'zekr_repeated_once'),
        style: TextStyle(
          fontFamily: _fontType,
          color: isFinish ? teal[400] : teal[700],
          fontSize: 12,
        ),
      ),
    );
  }
}
