import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

enum AnalyticsConsentDecision { allow, deny }

Future<AnalyticsConsentDecision> showAnalyticsConsentDialog(
  BuildContext context, {
  bool barrierDismissible = false,
}) async {
  final l10n = context.l10n;
  final result = await showAppDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    title: Text(l10n.analyticsConsentDialogTitle),
    content: Text(l10n.analyticsConsentDialogMessage),
    actions: [
      AppButton(
        label: l10n.analyticsConsentDeclineAction,
        variant: AppButtonVariant.ghost,
        onPressed: () => closeAppDialog(context, false),
      ),
      AppButton(
        label: l10n.analyticsConsentAllowAction,
        onPressed: () => closeAppDialog(context, true),
      ),
    ],
  );

  return result == true
      ? AnalyticsConsentDecision.allow
      : AnalyticsConsentDecision.deny;
}
