import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';
import 'package:azkark/features/refactor/sebha/presentation/modules/add_edit_sebha/add_edit_sebha_dialog.dart';
import 'package:azkark/features/refactor/sebha/presentation/modules/sebha_list/widgets/delete_sebha_dialog.dart';
import 'package:azkark/util/colors.dart';
import 'package:azkark/util/helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Replaces the legacy `PopUpMenuSebha` bottom sheet: copy / edit / delete
/// actions for one sebha item, driven by callbacks instead of reaching into
/// `SebhaProvider`/`FavoritesProvider` directly.
class SebhaItemMenuSheet extends StatelessWidget {
  const SebhaItemMenuSheet({
    super.key,
    required this.sebha,
    required this.onEdited,
    required this.onDelete,
  });

  final SebhaEntity sebha;
  final ValueChanged<SebhaEntity> onEdited;
  final ValueChanged<int> onDelete;

  static Future<void> show(
    BuildContext context, {
    required SebhaEntity sebha,
    required ValueChanged<SebhaEntity> onEdited,
    required ValueChanged<int> onDelete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SebhaItemMenuSheet(
        sebha: sebha,
        onEdited: onEdited,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: teal[50],
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildButton(
              context,
              title: tr('copy'),
              icon: Icons.content_copy,
              onTap: () {
                Navigator.pop(context);
                copyText(context, sebha.name);
              },
            ),
            const SizedBox(height: 15),
            _buildButton(
              context,
              title: tr('edit'),
              icon: Icons.edit,
              onTap: () async {
                Navigator.pop(context);
                final updated = await showDialog<SebhaEntity>(
                  context: context,
                  builder: (_) => AddEditSebhaDialog(existing: sebha),
                );
                if (updated != null) onEdited(updated);
              },
            ),
            const SizedBox(height: 15),
            _buildButton(
              context,
              title: tr('delete'),
              icon: Icons.delete_outline,
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => DeleteSebhaDialog(sebha: sebha),
                );
                if (confirmed == true) onDelete(sebha.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String title,
    required GestureTapCallback onTap,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        highlightColor: Theme.of(context).cardColor,
        splashColor: teal[200],
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(title, style: TextStyle(color: teal[600])),
              const SizedBox(width: 15),
              Icon(icon, size: 21, color: teal[600]),
            ],
          ),
        ),
      ),
    );
  }
}
