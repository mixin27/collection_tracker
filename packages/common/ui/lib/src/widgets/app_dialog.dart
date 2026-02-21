import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import 'app_card.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget content,
  Widget? title,
  List<Widget> actions = const [],
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: barrierDismissible,
    builder: (context) =>
        AppDialog(title: title, content: content, actions: actions),
  );
}

class AppDialog extends StatelessWidget {
  final Widget? title;
  final Widget content;
  final List<Widget> actions;

  const AppDialog({
    required this.content,
    this.title,
    this.actions = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              DefaultTextStyle.merge(
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                child: title!,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            content,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.end,
                  children: actions,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
