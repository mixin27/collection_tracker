import 'package:collection_tracker/core/analytics/analytics_consent_dialog.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';

class AnalyticsConsentGate extends ConsumerStatefulWidget {
  const AnalyticsConsentGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AnalyticsConsentGate> createState() =>
      _AnalyticsConsentGateState();
}

class _AnalyticsConsentGateState extends ConsumerState<AnalyticsConsentGate> {
  bool _dialogInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryPromptConsent();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(analyticsPreferencesProvider, (previous, next) {
      _tryPromptConsent();
    });

    return widget.child;
  }

  Future<void> _tryPromptConsent() async {
    if (!mounted || _dialogInProgress) return;

    final onboardingComplete =
        PrefsStorageService.instance.readSync<bool>('onboarding_complete') ??
        false;
    if (!onboardingComplete) return;

    final preferences = ref.read(analyticsPreferencesProvider);
    if (!preferences.needsConsent) return;

    _dialogInProgress = true;
    try {
      final decision = await showAnalyticsConsentDialog(context);
      if (!mounted) return;

      switch (decision) {
        case AnalyticsConsentDecision.allow:
          await ref.read(analyticsPreferencesProvider.notifier).grantConsent();
        case AnalyticsConsentDecision.deny:
          await ref.read(analyticsPreferencesProvider.notifier).denyConsent();
      }
    } finally {
      _dialogInProgress = false;
    }
  }
}
