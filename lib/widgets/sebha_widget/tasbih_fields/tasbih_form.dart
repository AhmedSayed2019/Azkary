import 'package:azkark/widgets/sebha_widget/tasbih_fields/row_button_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../models/sebha_model.dart';
import '../../../util/colors.dart';
import 'tasbih_text_field.dart';

class TasbihForm extends StatelessWidget {
  final String _title;
  final SebhaModel _tasbih;
  final GestureTapCallback? _onTapCancle, _onTapDone;
  final ValueChanged<String> _onChangedName, _onChangedCounter;

  const TasbihForm({
    required String title,
    required SebhaModel tasbih,
    required GestureTapCallback? onTapCancle,
    required GestureTapCallback? onTapDone,
    required ValueChanged<String> onChangedName,
    required ValueChanged<String> onChangedCounter,
  })  : _title = title,
        _tasbih = tasbih,
        _onTapCancle = onTapCancle,
        _onTapDone = onTapDone,
        _onChangedName = onChangedName,
        _onChangedCounter = onChangedCounter;

  bool get _isAdd => _tasbih.id == -1;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        _buildForm(context),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      right: -16.0,
      top: -16.0,
      child: InkResponse(
        onTap: _onTapCancle,
        child: CircleAvatar(
          radius: 18,
          child: Icon(
            Icons.close,
          ),
          backgroundColor: teal[600],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      onWillPop: () async {
        return false;
      },
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTitle(),
            TasbihTextField(
              text: _tasbih.name,
              hintText: tr( 'sebha_hint_text_tasbih'),
              maxlength: 250,
              maxLines: 2,
              autoFocus: true,
              onChanged: _onChangedName,
              onSubmitted: (text) => FocusScope.of(context).nextFocus(),
            ),
            TasbihTextField(
              text: _tasbih.counter.toString(),
              hintText: tr( 'sebha_hint_text_counter'),
              maxLines: 1,
              maxlength: 4,
              isNumber: true,
              isFinalField: true,
              onChanged: _onChangedCounter,
              onSubmitted: (text) {
                FocusScope.of(context).unfocus();
              },
            ),
            RowButtons(
              titleFirst: tr( _isAdd ? 'add' : 'edit'),
              titleSecond: tr( 'cancle'),
              onTapFirst: _onTapDone,
              onTapSecond: _onTapCancle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: Text(
        _title,
        style: TextStyle(
          color: teal[700],
          fontSize: 16,
        ),
      ),
    );
  }

}
