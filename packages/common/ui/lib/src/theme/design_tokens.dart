import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 360);
  static const Duration stagger = Duration(milliseconds: 42);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve standard = Curves.easeOut;
}

class AppGlass {
  static const double blurSigma = 18;
  static const double borderOpacity = 0.28;
  static const double shadowOpacity = 0.18;
}

@immutable
class DesignTokens extends ThemeExtension<DesignTokens> {
  final double navBarHeight;
  final double navBarHorizontalPadding;
  final double navBarBottomMargin;

  const DesignTokens({
    this.navBarHeight = 74,
    this.navBarHorizontalPadding = 16,
    this.navBarBottomMargin = 10,
  });

  @override
  DesignTokens copyWith({
    double? navBarHeight,
    double? navBarHorizontalPadding,
    double? navBarBottomMargin,
  }) {
    return DesignTokens(
      navBarHeight: navBarHeight ?? this.navBarHeight,
      navBarHorizontalPadding:
          navBarHorizontalPadding ?? this.navBarHorizontalPadding,
      navBarBottomMargin: navBarBottomMargin ?? this.navBarBottomMargin,
    );
  }

  @override
  DesignTokens lerp(ThemeExtension<DesignTokens>? other, double t) {
    if (other is! DesignTokens) return this;
    return DesignTokens(
      navBarHeight: lerpDouble(navBarHeight, other.navBarHeight, t)!,
      navBarHorizontalPadding: lerpDouble(
        navBarHorizontalPadding,
        other.navBarHorizontalPadding,
        t,
      )!,
      navBarBottomMargin: lerpDouble(
        navBarBottomMargin,
        other.navBarBottomMargin,
        t,
      )!,
    );
  }
}

double? lerpDouble(num? a, num? b, double t) {
  if (a == null && b == null) return null;
  if (a == null) return b!.toDouble();
  if (b == null) return a.toDouble();
  return a + (b - a) * t;
}
