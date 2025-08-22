import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sebha_model.dart';
import '../../providers/sebha_provider.dart';
import 'tasbih_fields/tasbih_form.dart';

class EditTasbih extends StatefulWidget {
  final String _title;
  final SebhaModel _tasbih;

  @override
  _EditTasbihState createState() => _EditTasbihState();

  const EditTasbih({
    required String title,
    required SebhaModel tasbih,
  })  : _title = title,
        _tasbih = tasbih;
}

class _EditTasbihState extends State<EditTasbih> {
  late SebhaModel _tasbih;

  @override
  void initState() {
    _tasbih = widget._tasbih;
    super.initState();
  }

  Future<void> _editTasbih() async {
    await Provider.of<SebhaProvider>(context, listen: false)
        .updateItemFromSebha(_tasbih);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      child: TasbihForm(
        title: tr( 'sebha_edit_dialog'),
        tasbih: _tasbih,
        onChangedName: (value) => setState(() {
          _tasbih.setName = value;
        }),
        onChangedCounter: (value) => setState(() {
          _tasbih.setCounter = int.parse(value);
        }),
        onTapCancle: () => Navigator.of(context).pop(false),
        onTapDone: () async {
          await _editTasbih();
          Navigator.of(context).pop(true);
        },
      ),
    );
  }
}
