import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final double blurSigma;
  final Color? borderColor;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const GlassSurface({
    required this.child,
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadii.xl)),
    this.padding = EdgeInsets.zero,
    this.blurSigma = AppGlass.blurSigma,
    this.borderColor,
    this.gradient,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveGradient =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.72),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.66),
          ],
        );

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: effectiveGradient,
            borderRadius: borderRadius,
            border: Border.all(
              color:
                  borderColor ??
                  theme.colorScheme.outlineVariant.withValues(
                    alpha: AppGlass.borderOpacity,
                  ),
              width: 1,
            ),
            boxShadow:
                boxShadow ??
                [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(
                      alpha: AppGlass.shadowOpacity,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}
