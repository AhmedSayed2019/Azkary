import 'package:azkark/features/refactor/sebha/domain/entity/sebha_entity.dart';
import 'package:azkark/features/refactor/sebha/presentation/modules/add_edit_sebha/add_edit_sebha_view_model.dart';
import 'package:azkark/providers.dart';
import 'package:azkark/util/colors.dart';
import 'package:azkark/widgets/sebha_widget/tasbih_fields/row_button_dialog.dart';
import 'package:azkark/widgets/sebha_widget/tasbih_fields/tasbih_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Add/edit dialog for a sebha item, backed by [AddEditSebhaViewModel].
/// Pass [existing] to edit; omit it to add a new item.
///
/// Pops with the saved [SebhaEntity] on success, or `null` if cancelled /
/// the save failed.
class AddEditSebhaDialog extends StatefulWidget {
  const AddEditSebhaDialog({super.key, this.existing});

  final SebhaEntity? existing;

  @override
  State<AddEditSebhaDialog> createState() => _AddEditSebhaDialogState();
}

class _AddEditSebhaDialogState extends State<AddEditSebhaDialog> {
  late final AddEditSebhaViewModel _vm;

  bool get _isAdd => widget.existing == null;

  @override
  void initState() {
    super.initState();
    _vm = getIt<AddEditSebhaViewModel>()..configure(widget.existing);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _onTapDone() async {
    final saved = await _vm.save(existing: widget.existing);
    // Bug fix: the legacy dialog used `context` after this await with no
    // `mounted` check, which could crash if the dialog was already closed.
    if (!mounted) return;
    if (saved != null) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isAdd ? tr('sebha_add_dialog') : tr('sebha_edit_dialog');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0.0,
      child: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) => Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            _buildForm(context, title),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      right: -16.0,
      top: -16.0,
      child: InkResponse(
        onTap: () => Navigator.of(context).pop(),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: teal[600],
          child: const Icon(Icons.close),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, String title) {
    return PopScope(
      canPop: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTitle(title),
            TasbihTextField(
              text: _vm.name,
              hintText: tr('sebha_hint_text_tasbih'),
              maxlength: 250,
              maxLines: 2,
              autoFocus: true,
              onChanged: _vm.onNameChanged,
              onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
            TasbihTextField(
              text: _vm.counter.toString(),
              hintText: tr('sebha_hint_text_counter'),
              maxLines: 1,
              maxlength: 4,
              isNumber: true,
              isFinalField: true,
              onChanged: _vm.onCounterChanged,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
            ),
            RowButtons(
              titleFirst: tr(_isAdd ? 'add' : 'edit'),
              titleSecond: tr('cancle'),
              onTapFirst: _vm.isSaving ? null : _onTapDone,
              onTapSecond: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Text(
        // Bug fix: the legacy dialog took a `title` constructor param but
        // never used it in build() (a string was hardcoded instead).
        title,
        style: TextStyle(color: teal[700], fontSize: 16),
      ),
    );
  }
}
