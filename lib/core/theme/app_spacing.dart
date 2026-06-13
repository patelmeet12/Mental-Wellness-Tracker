import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Custom gap widgets to avoid hardcoding SizedBox dimensions
  static const Widget gapXXS = SizedBox(width: xxs, height: xxs);
  static const Widget gapXS = SizedBox(width: xs, height: xs);
  static const Widget gapSM = SizedBox(width: sm, height: sm);
  static const Widget gapMD = SizedBox(width: md, height: md);
  static const Widget gapLG = SizedBox(width: lg, height: lg);
  static const Widget gapXL = SizedBox(width: xl, height: xl);
  static const Widget gapXXL = SizedBox(width: xxl, height: xxl);
}

class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  static BorderRadius borderXS = BorderRadius.circular(xs);
  static BorderRadius borderSM = BorderRadius.circular(sm);
  static BorderRadius borderMD = BorderRadius.circular(md);
  static BorderRadius borderLG = BorderRadius.circular(lg);
  static BorderRadius borderXL = BorderRadius.circular(xl);
  static BorderRadius borderXXL = BorderRadius.circular(xxl);
}

class AppElevations {
  AppElevations._();

  static const double none = 0.0;
  static const double card = 2.0;
  static const double dialog = 8.0;
}
