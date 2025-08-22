import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sebha_model.dart';
import '../../providers/sebha_provider.dart';
import 'tasbih_fields/tasbih_form.dart';

class AddTasbih extends StatefulWidget {
  final String _title;

  @override
  _AddTasbihState createState() => _AddTasbihState();

  const AddTasbih({
    required String title,
  }) : _title = title;
}

class _AddTasbihState extends State<AddTasbih> {
  late SebhaModel _tasbih;

  @override
  void initState() {
    _tasbih = SebhaModel(id: -1, name: '',counter:  0,favorite:  0);
    super.initState();
  }

  Future<void> _addTasbih() async {
    _tasbih.setFavorite(0);
    _tasbih.setId(Provider.of<SebhaProvider>(context, listen: false).newId);
    await Provider.of<SebhaProvider>(context, listen: false)
        .addItemToSebha(_tasbih);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      child: TasbihForm(
        title: tr( 'sebha_add_dialog'),
        tasbih: _tasbih,
        onChangedName: (value) => setState(() {
          _tasbih.setName = value;
        }),
        onChangedCounter: (value) => setState(() {
          _tasbih.setCounter = int.parse(value);
        }),
        onTapCancle: () => Navigator.of(context).pop(false),
        onTapDone: () async {
          await _addTasbih();
          Navigator.of(context).pop(true);
        },
      ),
    );
  }
}
