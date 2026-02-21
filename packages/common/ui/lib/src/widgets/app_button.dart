import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool isLoading;
  final bool expand;
  final AppButtonVariant variant;

  const AppButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.variant = AppButtonVariant.primary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final child = AnimatedSwitcher(
      duration: AppMotion.fast,
      switchInCurve: AppMotion.emphasized,
      switchOutCurve: AppMotion.standard,
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _foregroundColor(context),
              ),
            )
          : _ButtonContent(
              key: const ValueKey('content'),
              label: label,
              icon: icon,
            ),
    );

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: enabled ? onPressed : null,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: enabled ? onPressed : null,
        child: child,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: enabled ? onPressed : null,
        child: child,
      ),
      AppButtonVariant.danger => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        child: child,
      ),
    };

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  Color _foregroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (variant) {
      AppButtonVariant.primary => scheme.onPrimary,
      AppButtonVariant.secondary => scheme.onSurface,
      AppButtonVariant.ghost => scheme.primary,
      AppButtonVariant.danger => scheme.onError,
    };
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final Widget? icon;

  const _ButtonContent({required this.label, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon!,
        const SizedBox(width: AppSpacing.sm),
        Text(label),
      ],
    );
  }
}
