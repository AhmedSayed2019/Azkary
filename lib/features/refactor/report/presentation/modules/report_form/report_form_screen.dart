// نموذج البلاغ — يحلّ محل `FeedbackWebviewScreen`.
//
// كانت البلاغات تُفتح كنماذج Google داخل WebView: صفحة خارجية بخطّها
// وألوانها واتجاهها، تحتاج متصفحًا ومحرّك جافاسكربت، ولا تصل نتائجها إلا
// إلى جدول منفصل عن بقية بيانات التطبيق. الآن النموذج داخل التطبيق يتبع
// سمته ولغته، ويُكتب في مجموعة `reports` بمشروع Firebase.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/features/refactor/report/domain/entity/report_type.dart';
import 'package:azkark/features/refactor/report/presentation/modules/report_form/report_form_view_model.dart';
import 'package:azkark/providers.dart';
import 'package:azkark/widgets/islamic_header_background.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({
    super.key,
    this.initialType = ReportType.bug,
    this.reference,
    this.title,
  });

  /// النوع الذي تفتح به الشاشة. المستخدم يظل قادرًا على تغييره — من يفتح
  /// «إبلاغ عن مشكلة» ثم يكتشف أنه اقتراح لا ينبغي أن يعود من البداية.
  final ReportType initialType;

  /// سياق من الشاشة المُستدعية لا من المستخدم: نصّ الذكر أو الدعاء المُبلّغ
  /// عن خطأ فيه مثلًا. يُرسل مع البلاغ ولا يُعرض كحقل قابل للتحرير.
  final String? reference;

  /// عنوان بديل لشريط التطبيق.
  final String? title;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  late final ReportFormViewModel _vm;

  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _contact = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = getIt<ReportFormViewModel>();
    _vm.init(type: widget.initialType, reference: widget.reference);
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    _contact.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // إخفاء لوحة المفاتيح أولًا: النتيجة تظهر أسفل الزر، ولوحة المفاتيح
    // تغطيها تمامًا على الشاشات القصيرة.
    FocusScope.of(context).unfocus();
    await _vm.submit(
      subject: _subject.text,
      message: _message.text,
      contact: _contact.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackgroundColor.themeColor,
      appBar: AppBar(
        // نسيج النجوم الموحّد — انظر IslamicAppBar
        flexibleSpace: const IslamicHeaderBackground(child: SizedBox.expand()),
        backgroundColor: AppColor.primaryColor.themeColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.appBarIconsColor.themeColor),
        title: Text(
          widget.title?.trim().isNotEmpty == true
              ? widget.title!
              : 'report_title'.tr(),
          style: const TextStyle()
              .semiBoldStyle(fontSize: 16)
              .customColor(AppColor.appBarTextColor.themeColor),
        ),
      ),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) =>
            _vm.isSubmitted ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  // ------------------------------------------------------------------ النموذج

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        kScreenPaddingNormal.w,
        kScreenPaddingNormal.h,
        kScreenPaddingNormal.w,
        kScreenPaddingLarge.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('report_type'.tr()),
          SizedBox(height: kFormPaddingAllNormal.h),
          Wrap(
            spacing: kFormPaddingAllNormal.w,
            runSpacing: kFormPaddingAllNormal.h,
            children: [
              for (final type in ReportType.values)
                _TypeChip(
                  label: type.labelKey.tr(),
                  selected: _vm.type == type,
                  onTap: _vm.isSubmitting ? null : () => _vm.setType(type),
                ),
            ],
          ),

          // نصّ مُبلَّغ عنه وصل من الشاشة السابقة: يُعرض للاطمئنان إلى أنه
          // المقصود، بلا تحرير — المستخدم لم يكتبه ولا يملك تصحيحه هنا.
          if (widget.reference?.trim().isNotEmpty == true) ...[
            SizedBox(height: kScreenPaddingNormal.h),
            _ReferenceBox(text: widget.reference!.trim()),
          ],

          SizedBox(height: kScreenPaddingNormal.h),
          _Label('report_subject'.tr()),
          SizedBox(height: kFormPaddingAllNormal.h),
          _Field(
            controller: _subject,
            hint: 'report_subject_hint'.tr(),
            enabled: !_vm.isSubmitting,
            onChanged: (_) => _vm.clearErrors(),
            textInputAction: TextInputAction.next,
          ),

          SizedBox(height: kScreenPaddingNormal.h),
          _Label('report_message'.tr()),
          SizedBox(height: kFormPaddingAllNormal.h),
          _Field(
            controller: _message,
            hint: 'report_message_hint'.tr(),
            enabled: !_vm.isSubmitting,
            onChanged: (_) => _vm.clearErrors(),
            minLines: 5,
            maxLines: 10,
            textInputAction: TextInputAction.newline,
          ),

          SizedBox(height: kScreenPaddingNormal.h),
          _Label('report_contact'.tr()),
          SizedBox(height: kFormPaddingAllNormal.h),
          _Field(
            controller: _contact,
            hint: 'report_contact_hint'.tr(),
            enabled: !_vm.isSubmitting,
            onChanged: (_) => _vm.clearErrors(),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),

          if (_vm.validationError != null || _vm.submitErrorKey != null) ...[
            SizedBox(height: kFormPaddingAllNormal.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 16.r, color: AppColor.errorColor.themeColor),
                SizedBox(width: kFormPaddingAllSmall.w),
                Expanded(
                  child: Text(
                    (_vm.validationError?.messageKey ?? _vm.submitErrorKey!)
                        .tr(),
                    style: const TextStyle()
                        .mediumStyle(fontSize: 11.5)
                        .customColor(AppColor.errorColor.themeColor),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: kScreenPaddingNormal.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: _vm.isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor.themeColor,
                disabledBackgroundColor:
                    AppColor.primaryColor.themeColor.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kCardRadius.r),
                ),
              ),
              child: _vm.isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16.r,
                          height: 16.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: kFormPaddingAllNormal.w),
                        Text(
                          'report_sending'.tr(),
                          style: const TextStyle()
                              .semiBoldStyle(fontSize: 13)
                              .colorWhite(),
                        ),
                      ],
                    )
                  : Text(
                      'report_send'.tr(),
                      style: const TextStyle()
                          .semiBoldStyle(fontSize: 14)
                          .colorWhite(),
                    ),
            ),
          ),

          SizedBox(height: kFormPaddingAllLarge.h),
          Text(
            'report_privacy_note'.tr(),
            style: const TextStyle()
                .mediumStyle(fontSize: 10.5)
                .customColor(AppColor.hintColor.themeColor),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ النجاح

  Widget _buildSuccess() {
    final green = AppColor.primaryColor.themeColor;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(kScreenPaddingLarge.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: green.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, size: 38.r, color: green),
            ),
            SizedBox(height: kScreenPaddingNormal.h),
            Text(
              'report_success'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle()
                  .semiBoldStyle(fontSize: 15)
                  .primaryTextColor(),
            ),
            SizedBox(height: kFormPaddingAllNormal.h),
            // رقم مرجعي: يسمح للمستخدم بذكره حين يتابعنا، ويجعل إيجاد
            // المستند في لوحة Firebase فوريًا.
            Text(
              '#${_vm.submittedId}',
              style: const TextStyle()
                  .mediumStyle(fontSize: 11)
                  .customColor(AppColor.hintColor.themeColor),
            ),
            SizedBox(height: kScreenPaddingLarge.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kCardRadius.r),
                  ),
                ),
                child: Text(
                  'close'.tr(),
                  style: const TextStyle()
                      .semiBoldStyle(fontSize: 14)
                      .colorWhite(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- المكوّنات

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle()
          .semiBoldStyle(fontSize: 12.5)
          .customColor(AppColor.textSecondaryDark.themeColor),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.enabled,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kCardRadius.r),
      borderSide: BorderSide(color: AppColor.borderColor.themeColor),
    );

    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle().mediumStyle(fontSize: 13).primaryTextColor(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle()
            .mediumStyle(fontSize: 12)
            .customColor(AppColor.hintColor.themeColor),
        filled: true,
        fillColor: AppColor.backgroundColor.themeColor,
        contentPadding: EdgeInsets.all(kFormPaddingAllLarge.w),
        border: border,
        enabledBorder: border,
        disabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kCardRadius.r),
          borderSide: BorderSide(color: AppColor.primaryColor.themeColor),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final green = AppColor.primaryColor.themeColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: kFormPaddingAllLarge.w,
          vertical: kFormPaddingAllNormal.h,
        ),
        decoration: BoxDecoration(
          color: selected ? green : AppColor.grayScaleColor.themeColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? green : AppColor.borderColor.themeColor,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle().semiBoldStyle(fontSize: 12).customColor(
                selected ? Colors.white : AppColor.textSecondaryDark.themeColor,
              ),
        ),
      ),
    );
  }
}

class _ReferenceBox extends StatelessWidget {
  const _ReferenceBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kFormPaddingAllLarge.w),
      decoration: BoxDecoration(
        color: AppColor.grayScaleColor.themeColor,
        borderRadius: BorderRadius.circular(kCardRadius.r),
        border: Border.all(color: AppColor.borderColor.themeColor),
      ),
      child: Text(
        text,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle()
            .mediumStyle(fontSize: 12.5)
            .customColor(AppColor.textSecondaryDark.themeColor),
      ),
    );
  }
}
