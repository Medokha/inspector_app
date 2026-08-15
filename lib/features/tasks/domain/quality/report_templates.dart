/// نوع موقع الوقف لتحديد قالب التقرير.
enum WaqfSiteType {
  mosque,
  school,
  property,
  general,
}

extension WaqfSiteTypeX on WaqfSiteType {
  String get labelAr {
    switch (this) {
      case WaqfSiteType.mosque:
        return 'مسجد';
      case WaqfSiteType.school:
        return 'مدرسة';
      case WaqfSiteType.property:
        return 'عقار';
      case WaqfSiteType.general:
        return 'عام';
    }
  }

  static WaqfSiteType fromText(String? text) {
    final t = (text ?? '').toLowerCase();
    if (t.contains('مسجد') || t.contains('mosque')) return WaqfSiteType.mosque;
    if (t.contains('مدرسة') || t.contains('school') || t.contains('تعليمة')) {
      return WaqfSiteType.school;
    }
    if (t.contains('عقار') || t.contains('property') || t.contains('مبنى')) {
      return WaqfSiteType.property;
    }
    return WaqfSiteType.general;
  }
}

class ReportTemplateField {
  const ReportTemplateField({
    required this.id,
    required this.label,
    this.required = true,
    this.hint,
  });

  final String id;
  final String label;
  final bool required;
  final String? hint;
}

class ReportTemplate {
  const ReportTemplate({
    required this.siteType,
    required this.title,
    required this.fields,
    required this.checklist,
  });

  final WaqfSiteType siteType;
  final String title;
  final List<ReportTemplateField> fields;
  final List<ChecklistItemDef> checklist;
}

class ChecklistItemDef {
  const ChecklistItemDef({
    required this.id,
    required this.label,
    this.required = true,
  });

  final String id;
  final String label;
  final bool required;
}

/// قوالب التقرير حسب نوع الوقف + قائمة تحقق إلزامية.
class ReportTemplateCatalog {
  ReportTemplateCatalog._();

  static ReportTemplate forType(WaqfSiteType type) {
    switch (type) {
      case WaqfSiteType.mosque:
        return const ReportTemplate(
          siteType: WaqfSiteType.mosque,
          title: 'تقرير تفتيش مسجد',
          fields: <ReportTemplateField>[
            ReportTemplateField(id: 'prayer_hall', label: 'حالة قاعة الصلاة'),
            ReportTemplateField(id: 'ablution', label: 'وحدات الوضوء'),
            ReportTemplateField(id: 'minaret', label: 'المئذنة/الواجهة', required: false),
            ReportTemplateField(id: 'safety', label: 'السلامة والطوارئ'),
          ],
          checklist: <ChecklistItemDef>[
            ChecklistItemDef(id: 'photos_hall', label: 'التقط صور لقاعة الصلاة'),
            ChecklistItemDef(id: 'photos_outside', label: 'التقط صور للواجهة الخارجية'),
            ChecklistItemDef(id: 'check_clean', label: 'تأكد من نظافة الساحات'),
            ChecklistItemDef(id: 'check_utilities', label: 'راجع الكهرباء والمياه'),
          ],
        );
      case WaqfSiteType.school:
        return const ReportTemplate(
          siteType: WaqfSiteType.school,
          title: 'تقرير تفتيش مدرسة',
          fields: <ReportTemplateField>[
            ReportTemplateField(id: 'classrooms', label: 'حالة الصفوف'),
            ReportTemplateField(id: 'labs', label: 'المختبرات', required: false),
            ReportTemplateField(id: 'yard', label: 'الساحة والمرافق'),
            ReportTemplateField(id: 'safety', label: 'السلامة المدرسية'),
          ],
          checklist: <ChecklistItemDef>[
            ChecklistItemDef(id: 'photos_class', label: 'صور للصفوف'),
            ChecklistItemDef(id: 'photos_yard', label: 'صور للساحة'),
            ChecklistItemDef(id: 'check_exits', label: 'تحقق من مخارج الطوارئ'),
            ChecklistItemDef(id: 'check_hygiene', label: 'تحقق من النظافة الصحية'),
          ],
        );
      case WaqfSiteType.property:
        return const ReportTemplate(
          siteType: WaqfSiteType.property,
          title: 'تقرير تفتيش عقار',
          fields: <ReportTemplateField>[
            ReportTemplateField(id: 'structure', label: 'الهيكل الإنشائي'),
            ReportTemplateField(id: 'facade', label: 'الواجهة والتشطيب'),
            ReportTemplateField(id: 'utilities', label: 'الخدمات (ماء/كهرباء)'),
            ReportTemplateField(id: 'occupancy', label: 'الإشغال/الاستخدام', required: false),
          ],
          checklist: <ChecklistItemDef>[
            ChecklistItemDef(id: 'photos_facade', label: 'صور الواجهة'),
            ChecklistItemDef(id: 'photos_inside', label: 'صور داخلية'),
            ChecklistItemDef(id: 'check_damage', label: 'توثيق أي أضرار ظاهرة'),
            ChecklistItemDef(id: 'check_access', label: 'تحقق من سهولة الوصول'),
          ],
        );
      case WaqfSiteType.general:
        return const ReportTemplate(
          siteType: WaqfSiteType.general,
          title: 'تقرير تفتيش عام',
          fields: <ReportTemplateField>[
            ReportTemplateField(id: 'general', label: 'الحالة العامة'),
            ReportTemplateField(id: 'notes', label: 'ملاحظات إضافية', required: false),
          ],
          checklist: <ChecklistItemDef>[
            ChecklistItemDef(id: 'photos_min', label: 'أرفق صورة واحدة على الأقل'),
            ChecklistItemDef(id: 'check_condition', label: 'حدد الحالة العامة للموقع'),
            ChecklistItemDef(id: 'check_violations', label: 'راجع وجود مخالفات'),
          ],
        );
    }
  }

  static ReportTemplate detectFromTask({String? title, String? description}) {
    final type = WaqfSiteTypeX.fromText('${title ?? ''} ${description ?? ''}');
    return forType(type);
  }
}

/// حالة قائمة التحقق قبل الرفع.
class ChecklistState {
  ChecklistState(this.definitions)
      : checked = {for (final d in definitions) d.id: false};

  final List<ChecklistItemDef> definitions;
  final Map<String, bool> checked;

  void setChecked(String id, bool value) => checked[id] = value;

  bool get allRequiredDone => definitions
      .where((d) => d.required)
      .every((d) => checked[d.id] == true);

  List<ChecklistItemDef> get missingRequired =>
      definitions.where((d) => d.required && checked[d.id] != true).toList();

  String? validate() {
    if (allRequiredDone) return null;
    final missing = missingRequired.map((e) => e.label).join('، ');
    return 'أكمل قائمة التحقق أولاً: $missing';
  }
}
