import 'package:equatable/equatable.dart';

import 'package:azkark/features/refactor/report/domain/entity/report_type.dart';

/// بلاغ كما كتبه المستخدم، قبل أن تُضاف إليه بيانات البيئة.
///
/// البيئة (إصدار التطبيق، النظام، اللغة) ليست جزءًا من هذا الكيان عمدًا:
/// المستخدم لا يكتبها ولا يراها في النموذج، وطبقة البيانات هي من تلتقطها
/// لحظة الإرسال — فلا معنى لأن يحملها كيان النموذج ويُجبر كل مستدعٍ على
/// تعبئتها.
class ReportDraftEntity extends Equatable {
  const ReportDraftEntity({
    required this.type,
    required this.message,
    this.subject = '',
    this.contact = '',
    this.reference,
  });

  final ReportType type;

  /// وصف المشكلة أو الاقتراح — الحقل الوحيد الإلزامي.
  final String message;

  /// ملخّص سطر واحد. اختياري: إلزامه يدفع المستخدمين لكتابة «مشكلة» ثم
  /// تكرار كل شيء في التفاصيل.
  final String subject;

  /// بريد للردّ. فارغ يعني «لا تردّوا عليّ»، وهو خيار مشروع.
  final String contact;

  /// سياق يأتي من الشاشة لا من المستخدم — نصّ الذكر أو الدعاء المُبلّغ عن
  /// خطأ فيه مثلًا. كان يُمرَّر سابقًا في رابط النموذج المُعبَّأ مسبقًا.
  final String? reference;

  @override
  List<Object?> get props => [type, message, subject, contact, reference];
}
