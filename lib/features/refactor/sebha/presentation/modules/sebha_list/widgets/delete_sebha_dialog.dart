import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';
import 'package:azkark/util/colors.dart';
import 'package:azkark/widgets/sebha_widget/tasbih_fields/row_button_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Confirmation dialog for deleting a sebha item. Pops `true`/`false`; the
/// caller is responsible for actually performing the delete through the
/// view model (this dialog has no data-layer dependency itself).
class DeleteSebhaDialog extends StatelessWidget {
  const DeleteSebhaDialog({super.key, required this.sebha});

  final SebhaEntity sebha;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTitle(),
              _buildSubTitle(),
              RowButtons(
                titleFirst: tr('delete'),
                titleSecond: tr('cancle'),
                onTapFirst: () => Navigator.of(context).pop(true),
                onTapSecond: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      right: -16.0,
      top: -16.0,
      child: InkResponse(
        onTap: () => Navigator.of(context).pop(false),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: teal[600],
          child: const Icon(Icons.close),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Text(
        tr('sebha_delete_dialog_title'),
        style: TextStyle(color: teal[700], fontSize: 18),
      ),
    );
  }

  Widget _buildSubTitle() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Text(
        tr('sebha_delete_dialog_subtitle'),
        style: TextStyle(color: teal[500], fontSize: 16),
      ),
    );
  }
}
