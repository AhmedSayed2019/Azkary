import 'package:azkark/core/res/resources.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../util/colors.dart';

class SettingsItem extends StatefulWidget 
{
  final String _activeTitle,_inactiveTitle,_nameField;
  final BorderRadius? _borderRadius;
  final bool? _switchValue;
  final ValueChanged<bool>? _onChanged;

  @override
  _SettingsItemState createState() => _SettingsItemState();

  const SettingsItem({
    required String activeTitle,
    required String inactiveTitle,
    required String nameField,
     bool? switchValue,
     ValueChanged<bool>? onChanged,

    BorderRadius? borderRadius,
  })  : _activeTitle = activeTitle,
        _inactiveTitle = inactiveTitle,
        _switchValue = switchValue,
        _onChanged = onChanged,
        _nameField = nameField,
        _borderRadius = borderRadius;
}

class _SettingsItemState extends State<SettingsItem> 
{
  late bool switchValue;
  
  @override
  void initState() {
    super.initState();
    switchValue=widget._switchValue??Provider.of<SettingsProvider>(context,listen: false).getsettingField(widget._nameField);
  }

  @override
  Widget build(BuildContext context) 
  {
    final settingsProvider=Provider.of<SettingsProvider>(context,listen: false);
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: teal[200],
      onTap: () async {
        setState(() {
          switchValue=!switchValue;
        });
        print('InkWell $switchValue');
        int value= switchValue ? 1: 0;
        await settingsProvider.updateSettings(widget._nameField,value);
      },
      borderRadius: widget._borderRadius,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                switchValue ? widget._activeTitle : widget._inactiveTitle,
                style:  const TextStyle().semiBoldStyle().primaryTextColor(),
                // style: const TextStyle(
                //   color: teal,
                //   fontSize: 14,
                // ),
              ),
            ),
            Switch(
              onChanged: (value) async {
                print('Switch $switchValue');
                setState(() {
                  switchValue=value;
                });
                int valueInt= switchValue ? 1: 0;
                if( widget._onChanged!=null){
                  print('_onChanged $switchValue');
                  widget._onChanged!(switchValue);
                }else{
                  await settingsProvider.updateSettings(widget._nameField,valueInt);
                }
              },
              value: switchValue,
              activeColor: teal[700],
              activeTrackColor: teal[500],
              inactiveThumbColor: teal[200],
              inactiveTrackColor: Theme.of(context).cardColor,
            ),
          ],
        ),
      ),
    );
  }
}