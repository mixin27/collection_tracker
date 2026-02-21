import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import 'glass_surface.dart';

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    builder: (context) => AppSheet(child: builder(context)),
  );
}

class AppSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final bool showHandle;

  const AppSheet({
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
    ),
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.lg,
    ),
    this.showHandle = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    final resolvedMargin = margin.resolve(Directionality.of(context));
    final maxHeight = math.max<double>(
      220,
      mediaQuery.size.height -
          mediaQuery.padding.top -
          viewInsets.bottom -
          resolvedMargin.vertical,
    );

    return AnimatedPadding(
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: margin,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: GlassSurface(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              padding: padding,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showHandle)
                      Container(
                        width: 38,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                      ),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
