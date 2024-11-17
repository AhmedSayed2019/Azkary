import '../../util/helpers.dart';
import '../../widgets/sebha_widget/edit_tasbih_dialog.dart';
import '../../models/sebha_model.dart';
import '../../util/colors.dart';
import 'package:flutter/material.dart';
import 'delete_dialog.dart';

class PopUpMenuSebha extends StatelessWidget {
  final SebhaModel _tasbih;
  final BuildContext _buildContext;
  const PopUpMenuSebha({
    required SebhaModel tasbih,
    required BuildContext buildContext,
  })  : _tasbih = tasbih,
        _buildContext = buildContext;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: teal[50],
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildButton(
              title: translate(context, 'copy'),
              icon: Icons.content_copy,
              onTap: () async {
                Navigator.pop(context);
                copyText(_buildContext, _tasbih.name);
              },
            ),
            SizedBox(
              height: 15,
            ),
            _buildButton(
              title: translate(context, 'edit'),
              icon: Icons.edit,
              onTap: () async {
                Navigator.pop(context);
                await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => EditTasbih(
                    title: translate(context, 'sebha_edit_dialog'),
                    tasbih: _tasbih,
                  ),
                );
              },
            ),
            SizedBox(
              height: 15,
            ),
            _buildButton(
              title: translate(context, 'delete'),
              icon: Icons.delete_outline,
              onTap: () async {
                Navigator.pop(context);
                await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => DeleteDialog(
                    tasbihFavorite: _tasbih.favorite,
                    tasbihId: _tasbih.id,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required String title,required GestureTapCallback onTap,required IconData icon}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        highlightColor: teal[300],
        splashColor: teal[200],
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: teal[600],
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Icon(
                icon,
                size: 21,
                color: teal[600],
              ),
            ],
          ),
        ),
      ),
    );
  }


}
