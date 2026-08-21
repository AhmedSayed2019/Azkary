/// تعريف المصاحف المتاحة للتحميل والعرض.
///
/// هذا الملف هو نقطة البداية لمعمارية "renderer موحد لعدة مصاحف" (راجع
/// النقاش في هذا الفرع): كل مصحف (V2, V4, إندوباك...) له نفس الشكل هنا —
/// معرّف، اسم، عدد الصفحات، عدد الأسطر بالصفحة، ورابط تنزيل حزمة تحوي
/// الخطوط + قاعدة تخطيط (layout.db بصيغة QUL).
///
/// ملاحظة استضافة مهمة (نفس ما ورد في نقاش التصميم): لا يُعتمد على روابط
/// QUL مباشرة في الإنتاج — نزّل الحزم مرة واحدة وأعد رفعها على خادم/CDN
/// خاص بالتطبيق (لا ضمان ثبات لروابط QUL الخام ولا SLA عليها).
///
/// الحالة الحالية: هذا تعريف بيانات فقط (registry). التنزيل الفعلي
/// (`mushaf_downloader.dart`) وقراءة التخطيط (`layout_repository.dart`)
/// ومحرك الرسم (`engine/`) لم تُبنَ بعد — تحتاج عيّنة حقيقية من
/// `layout.db` (من qul.tarteel.ai/resources/mushaf-layouts) لكتابة
/// استعلامات SQLite مطابقة للبنية الفعلية بدل افتراضها.
class MushafDefinition {
  const MushafDefinition({
    required this.id,
    required this.nameAr,
    required this.totalPages,
    required this.linesPerPage,
    required this.downloadUrl,
    required this.sizeInMB,
  });

  /// معرّف فريد وثابت للمصحف، يُستخدم كمفتاح تخزين/تسمية مجلد التنزيل
  /// وبادئة أسماء عائلات الخطوط (مثال: 'qcf_v2', 'qcf_v4', 'indopak_15').
  final String id;

  /// الاسم المعروض للمستخدم.
  final String nameAr;

  /// عدد صفحات هذا المصحف (يختلف بين المصاحف: 604 للمدني، 610 للإندوباك
  /// مثلاً) — الفهرسة/التنقل يجب أن يتم بمرجعية سورة+آية عند التبديل بين
  /// مصحفين لأن رقم الصفحة لنفس الآية يختلف.
  final int totalPages;

  /// عدد الأسطر في الصفحة الواحدة (عادة 15 أو 16).
  final int linesPerPage;

  /// رابط حزمة (zip) تحوي مجلد `fonts/` وملف `layout.db`. يُفضَّل أن يشير
  /// لخادم/CDN خاص بالتطبيق بعد إعادة رفع الحزمة، وليس لرابط QUL مباشر.
  final String downloadUrl;

  /// الحجم التقريبي بالميجابايت (لعرضه للمستخدم قبل التنزيل، مثلاً عبر
  /// شبكة بيانات الهاتف).
  final int sizeInMB;
}

/// قائمة المصاحف المتاحة. أضف هنا أي مصحف جديد بعد رفع حزمته (خطوط +
/// layout.db) على خادم/CDN التطبيق.
///
/// TODO: `downloadUrl` أدناه عناصر نائبة (placeholders) — لا تشير حاليًا
/// لحزم فعلية. يجب استبدالها بروابط حقيقية بعد تجهيز الحزم.
const List<MushafDefinition> mushafs = [
  MushafDefinition(
    id: 'qcf_v2',
    nameAr: 'مصحف المدينة',
    totalPages: 604,
    linesPerPage: 15,
    downloadUrl: '', // TODO: رابط حزمة qcf_v2 بعد رفعها على خادم التطبيق
    sizeInMB: 0,
  ),
  MushafDefinition(
    id: 'qcf_v4',
    nameAr: 'مصحف التجويد الملون',
    totalPages: 604,
    linesPerPage: 15,
    downloadUrl: '', // TODO: رابط حزمة qcf_v4 بعد رفعها على خادم التطبيق
    sizeInMB: 0,
  ),
  MushafDefinition(
    id: 'indopak_15',
    nameAr: 'المصحف الهندي',
    totalPages: 610,
    linesPerPage: 15,
    downloadUrl: '', // TODO: رابط حزمة indopak_15 بعد رفعها على خادم التطبيق
    sizeInMB: 0,
  ),
];
