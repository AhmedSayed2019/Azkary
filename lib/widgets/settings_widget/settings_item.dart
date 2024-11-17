import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../util/colors.dart';
import 'package:flutter/material.dart';

class SettingsItem extends StatefulWidget 
{
  final String _activeTitle,_inactiveTitle,_nameField;
  final BorderRadius? _borderRadius;

  @override
  _SettingsItemState createState() => _SettingsItemState();

  const SettingsItem({
    required String activeTitle,
    required String inactiveTitle,
    required String nameField,
     BorderRadius? borderRadius,
  })  : _activeTitle = activeTitle,
        _inactiveTitle = inactiveTitle,
        _nameField = nameField,
        _borderRadius = borderRadius;
}

class _SettingsItemState extends State<SettingsItem> 
{
  late bool switchValue;
  
  @override
  void initState() 
  {
    super.initState();
    switchValue=Provider.of<SettingsProvider>(context,listen: false).getsettingField(widget._nameField);
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
                style: new TextStyle(
                  color: teal,
                  fontSize: 14,
                ),
              ),
            ),
            Switch(
              onChanged: (value) async {
                print('Switch $switchValue');
                setState(() {
                  switchValue=value;
                });
                int valueInt= switchValue ? 1: 0;
                await settingsProvider.updateSettings(widget._nameField,valueInt);
              },
              value: switchValue,
              activeColor: teal[700],
              activeTrackColor: teal[500],
              inactiveThumbColor: teal[200],
              inactiveTrackColor: teal[300],
            ),
          ],
        ),
      ),
    );
  }
}