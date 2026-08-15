import 'dart:math' as math;

import 'package:flutter/material.dart';

/// أدوات تكيّف الواجهة مع أحجام الشاشات المختلفة.
class Responsive {
  Responsive._();

  static const double compactWidth = 360;
  static const double mediumWidth = 600;
  static const double expandedWidth = 840;
  static const double contentMaxWidth = 720;

  static Size sizeOf(BuildContext context) => MediaQuery.sizeOf(context);

  static double widthOf(BuildContext context) => sizeOf(context).width;

  static double heightOf(BuildContext context) => sizeOf(context).height;

  static bool isCompact(BuildContext context) => widthOf(context) < mediumWidth;

  static bool isTablet(BuildContext context) =>
      sizeOf(context).shortestSide >= mediumWidth;

  static bool isNarrow(BuildContext context) => widthOf(context) < compactWidth;

  static bool isShort(BuildContext context) => heightOf(context) < 640;

  /// هوامش أفقية تتناسب مع عرض الشاشة.
  static double pagePadding(BuildContext context) {
    final w = widthOf(context);
    if (w < compactWidth) return 12;
    if (w < mediumWidth) return 16;
    if (w < expandedWidth) return 24;
    return 32;
  }

  /// يقيّد عرض المحتوى على الشاشات العريضة ويوسّطه مع ملء الارتفاع.
  static Widget constrainWidth({
    required Widget child,
    double maxWidth = contentMaxWidth,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? math.min(constraints.maxWidth, maxWidth)
            : maxWidth;
        final height = constraints.maxHeight.isFinite ? constraints.maxHeight : null;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        );
      },
    );
  }

  static double logoSize(BuildContext context, {double max = 200, double min = 120}) {
    final w = widthOf(context);
    final h = heightOf(context);
    final byWidth = w * 0.42;
    final byHeight = h * 0.22;
    return math.min(max, math.max(min, math.min(byWidth, byHeight)));
  }

  static double mapEmbedHeight(BuildContext context, {double preferred = 280}) {
    final h = heightOf(context);
    final capped = h * (isShort(context) ? 0.28 : 0.34);
    return math.max(180, math.min(preferred, capped));
  }

  /// يقلل تسميات شريط التنقل على الشاشات الضيقة.
  static NavigationDestinationLabelBehavior navLabelBehavior(BuildContext context) {
    if (widthOf(context) < compactWidth) {
      return NavigationDestinationLabelBehavior.onlyShowSelected;
    }
    return NavigationDestinationLabelBehavior.alwaysShow;
  }
}

/// يلف محتوى الصفحة بهوامش متجاوبة وعرض أقصى على الأجهزة الكبيرة.
class ResponsivePageBody extends StatelessWidget {
  const ResponsivePageBody({
    super.key,
    required this.child,
    this.maxWidth = Responsive.contentMaxWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final horizontal = Responsive.pagePadding(context);
    return Responsive.constrainWidth(
      maxWidth: maxWidth,
      child: Padding(
        padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
        child: child,
      ),
    );
  }
}
