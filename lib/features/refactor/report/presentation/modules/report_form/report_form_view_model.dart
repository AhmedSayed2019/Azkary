import 'package:flutter/foundation.dart';

import 'package:azkark/core/result.dart';
import 'package:azkark/features/refactor/report/domain/entity/report_draft_entity.dart';
import 'package:azkark/features/refactor/report/domain/entity/report_type.dart';
import 'package:azkark/features/refactor/report/domain/usecase/submit_report_use_case.dart';

/// سبب رفض النموذج. مفاتيح ترجمة تُحلّها الشاشة لا نصوص جاهزة: نموذج
/// العرض لا يملك سياق ترجمة، وإرجاعه نصًّا عربيًا كان سيتجاهل لغة المستخدم.
enum ReportValidationError {
  messageRequired('report_message_required'),
  messageTooShort('report_message_too_short'),
  contactInvalid('report_contact_invalid');

  const ReportValidationError(this.messageKey);

  final String messageKey;
}

class ReportFormViewModel extends ChangeNotifier {
  final _tag = 'ReportFormViewModel';

  ReportFormViewModel({required SubmitReportUseCase submitReport})
      : _submitReport = submitReport;

  final SubmitReportUseCase _submitReport;
  bool _disposed = false;

  /// أقصر وصف مفيد. أي شيء أقصر («لا يعمل») لا يمكن التصرّف بناءً عليه،
  /// ورفضه قبل الإرسال أفضل من بلاغ يُغلق بلا نتيجة.
  static const int minMessageLength = 10;

  ///Variables
  ReportType _type = ReportType.bug;
  String? _reference;
  bool _isSubmitting = false;
  ReportValidationError? _validationError;

  /// مفتاح ترجمة لفشل الإرسال نفسه (شبكة/صلاحيات)، لا لخطأ في المُدخلات.
  String? _submitErrorKey;

  /// معرّف مستند البلاغ بعد نجاح الإرسال — وجوده هو «تم الإرسال».
  String? _submittedId;

  ///Getters
  ReportType get type => _type;

  bool get isSubmitting => _isSubmitting;

  ReportValidationError? get validationError => _validationError;

  String? get submitErrorKey => _submitErrorKey;

  String? get submittedId => _submittedId;

  bool get isSubmitted => _submittedId != null;

  /// Entry point — تُستدعى مرة من `initState`. [type] النوع المبدئي الذي
  /// فتحت به الشاشة، و[reference] سياق من الشاشة (نصّ الذكر المُبلَّغ عنه).
  void init({ReportType type = ReportType.bug, String? reference}) {
    _type = type;
    _reference = reference;
  }

  void setType(ReportType value) {
    if (_type == value) return;
    _type = value;
    _notify();
  }

  /// تُستدعى عند كل تعديل في الحقول: رسالة خطأ باقية بعد أن صحّح المستخدم
  /// ما فيها تجعل النموذج يبدو معطلًا.
  void clearErrors() {
    if (_validationError == null && _submitErrorKey == null) return;
    _validationError = null;
    _submitErrorKey = null;
    _notify();
  }

  ///Calling API functions

  Future<void> submit({
    required String subject,
    required String message,
    required String contact,
  }) async {
    if (_isSubmitting) return;

    final error = _validate(message: message, contact: contact);
    if (error != null) {
      _validationError = error;
      _submitErrorKey = null;
      _notify();
      return;
    }

    _isSubmitting = true;
    _validationError = null;
    _submitErrorKey = null;
    _notify();

    final result = await _submitReport(
      ReportDraftEntity(
        type: _type,
        subject: subject,
        message: message,
        contact: contact,
        reference: _reference,
      ),
    );

    switch (result) {
      case Ok(:final data):
        _submittedId = data;
      case Err(:final message):
        _submitErrorKey = 'report_failed';
        debugPrint('$_tag.submit: $message');
    }

    _isSubmitting = false;
    _notify();
  }

  ReportValidationError? _validate({
    required String message,
    required String contact,
  }) {
    final body = message.trim();
    if (body.isEmpty) return ReportValidationError.messageRequired;
    if (body.length < minMessageLength) {
      return ReportValidationError.messageTooShort;
    }

    final email = contact.trim();
    // فحص متساهل عمدًا: الحقل اختياري وليس بوابة دخول، ورفض بريد صحيح
    // بنمط متشدد يكلّفنا بلاغًا كاملًا.
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return ReportValidationError.contactInvalid;
    }
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }
}
