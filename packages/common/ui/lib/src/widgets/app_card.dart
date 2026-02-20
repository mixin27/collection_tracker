import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? borderColor;

  const AppCard({
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(AppRadii.lg);

    final surface = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? theme.colorScheme.outlineVariant,
        ),
      ),
      child: child,
    );

    final clickable = onTap != null || onLongPress != null
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: RoundedRectangleBorder(borderRadius: radius),
              onTap: onTap,
              onLongPress: onLongPress,
              child: surface,
            ),
          )
        : surface;

    return Padding(padding: margin ?? EdgeInsets.zero, child: clickable);
  }
}
