import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../../domain/app_update_models.dart';
import '../providers/app_update_providers.dart';

class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate>
    with WidgetsBindingObserver {
  bool _dialogInProgress = false;
  String? _lastPromptedSignature;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndMaybePrompt(trigger: 'startup');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndMaybePrompt(trigger: 'resume');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> _checkAndMaybePrompt({required String trigger}) async {
    if (!mounted || _dialogInProgress) {
      return;
    }

    final result = await ref
        .read(appUpdateControllerProvider.notifier)
        .checkIfDue(trigger: trigger);
    if (!mounted || result == null) {
      return;
    }

    if (result.status != AppUpdateStatus.updateAvailable &&
        result.status != AppUpdateStatus.updateRequired) {
      return;
    }

    if (_lastPromptedSignature == result.signature &&
        !result.isForceUpdate &&
        trigger == 'resume') {
      return;
    }

    _dialogInProgress = true;
    _lastPromptedSignature = result.signature;

    try {
      final action = await showAppDialog<_UpdateAction>(
        context: context,
        barrierDismissible: !result.isForceUpdate,
        title: Text(_titleFor(result)),
        content: Text(_messageFor(result)),
        actions: [
          if (!result.isForceUpdate)
            AppButton(
              label: 'Later',
              variant: AppButtonVariant.ghost,
              onPressed: () => closeAppDialog(context, _UpdateAction.later),
            ),
          if (result.hasStoreUrl)
            AppButton(
              label: result.isForceUpdate ? 'Update Now' : 'Update',
              onPressed: () => closeAppDialog(context, _UpdateAction.update),
            ),
        ],
      );

      if (!mounted) {
        return;
      }

      switch (action) {
        case _UpdateAction.update:
          await ref
              .read(appUpdateControllerProvider.notifier)
              .openStore(result);
        case _UpdateAction.later:
          if (!result.isForceUpdate) {
            await ref
                .read(appUpdateControllerProvider.notifier)
                .snoozeCurrent(hours: result.snoozeHours);
          }
        case null:
          if (!result.isForceUpdate) {
            await ref
                .read(appUpdateControllerProvider.notifier)
                .snoozeCurrent(hours: result.snoozeHours);
          }
      }
    } finally {
      _dialogInProgress = false;
    }
  }

  String _titleFor(AppUpdateResult result) {
    final custom = result.title?.trim();
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }
    return result.isForceUpdate ? 'Update Required' : 'Update Available';
  }

  String _messageFor(AppUpdateResult result) {
    final custom = result.message?.trim();
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }

    final latest = result.latestVersion?.trim();
    final minimum = result.minSupportedVersion?.trim();

    if (result.isForceUpdate) {
      if (minimum != null && minimum.isNotEmpty) {
        return 'This version is no longer supported. Update to continue (minimum: $minimum).';
      }
      return 'A newer app version is required to continue.';
    }

    if (latest != null && latest.isNotEmpty) {
      return 'A newer version ($latest) is available with improvements and fixes.';
    }
    return 'A newer app version is available.';
  }
}

enum _UpdateAction { later, update }
