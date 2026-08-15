import 'package:flutter/material.dart';

/// مسافات آمنة تتجنب تغطية أزرار النظام / الشريط السفلي.
class ScreenInsets {
  ScreenInsets._();

  static double bottom(BuildContext context, {double extra = 16}) {
    return MediaQuery.viewPaddingOf(context).bottom + extra;
  }

  static EdgeInsets list(BuildContext context, {
    double horizontal = 16,
    double top = 16,
    double extraBottom = 24,
  }) {
    return EdgeInsets.fromLTRB(
      horizontal,
      top,
      horizontal,
      bottom(context, extra: extraBottom),
    );
  }
}
