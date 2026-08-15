/// عرض واضح لسجل التدقيق (من عدّل / أعاد إسناد / اعتمد).
class AuditTrailEntry {
  const AuditTrailEntry({
    required this.actionRaw,
    required this.fromStatus,
    required this.toStatus,
    required this.performedBy,
    required this.at,
    this.notes,
    this.rejectionReason,
  });

  final String actionRaw;
  final String fromStatus;
  final String toStatus;
  final String performedBy;
  final DateTime at;
  final String? notes;
  final String? rejectionReason;

  String get actionLabelAr {
    final a = actionRaw.toLowerCase();
    if (a.contains('create') || a.contains('إنشاء')) return 'إنشاء المهمة';
    if (a.contains('start') || a.contains('بدء')) return 'بدء المهمة';
    if (a.contains('submit') || a.contains('تقرير')) return 'رفع التقرير';
    if (a.contains('approve') || a.contains('اعتماد')) return 'اعتماد التقرير';
    if (a.contains('reject') || a.contains('رفض')) return 'رفض التقرير';
    if (a.contains('reassign') || a.contains('إسناد')) return 'إعادة إسناد';
    if (a.contains('smartreschedule') || a.contains('جدولة')) return 'إعادة جدولة ذكية';
    return actionRaw.isEmpty ? 'تحديث' : actionRaw;
  }

  String get summaryAr {
    final buf = StringBuffer(actionLabelAr);
    if (fromStatus.isNotEmpty || toStatus.isNotEmpty) {
      buf.write(' ($fromStatus → $toStatus)');
    }
    if (rejectionReason != null && rejectionReason!.trim().isNotEmpty) {
      buf.write(' — سبب: ${rejectionReason!.trim()}');
    } else if (notes != null && notes!.trim().isNotEmpty) {
      buf.write(' — ${notes!.trim()}');
    }
    return buf.toString();
  }
}

class AuditTrailPresenter {
  AuditTrailPresenter._();

  static List<AuditTrailEntry> fromHistoryMaps(List<Map<String, dynamic>> rows) {
    return rows.map((r) {
      return AuditTrailEntry(
        actionRaw: r['action']?.toString() ?? r['Action']?.toString() ?? '',
        fromStatus: r['fromStatus']?.toString() ?? r['FromStatus']?.toString() ?? '',
        toStatus: r['toStatus']?.toString() ?? r['ToStatus']?.toString() ?? '',
        performedBy: r['performedByUserId']?.toString() ??
            r['PerformedByUserId']?.toString() ??
            r['performedBy']?.toString() ??
            '—',
        at: DateTime.tryParse(
              r['createdAt']?.toString() ??
                  r['CreatedAt']?.toString() ??
                  r['date']?.toString() ??
                  '',
            ) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        notes: r['notes']?.toString() ?? r['Notes']?.toString(),
        rejectionReason: r['rejectionReason']?.toString() ?? r['RejectionReason']?.toString(),
      );
    }).toList()
      ..sort((a, b) => a.at.compareTo(b.at));
  }
}
