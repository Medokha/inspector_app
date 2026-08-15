import 'package:flutter/material.dart';

import 'package:inspector_app/core/ui/responsive.dart';

/// مسافات آمنة تتجنب تغطية أزرار النظام / الشريط السفلي.
class ScreenInsets {
  ScreenInsets._();

  /// أسفل الشاشة. استخدم [insideShell]=true لصفحات التبويب لأن SafeArea
  /// حول شريط التنقل يغطي بالفعل مساحة النظام.
  static double bottom(
    BuildContext context, {
    double extra = 16,
    bool insideShell = false,
  }) {
    if (insideShell) return extra;
    return MediaQuery.viewPaddingOf(context).bottom + extra;
  }

  static EdgeInsets list(
    BuildContext context, {
    double? horizontal,
    double top = 16,
    double extraBottom = 24,
    bool insideShell = false,
  }) {
    final h = horizontal ?? Responsive.pagePadding(context);
    return EdgeInsets.fromLTRB(
      h,
      top,
      h,
      bottom(context, extra: extraBottom, insideShell: insideShell),
    );
  }
}
