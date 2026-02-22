import 'package:app_logger/app_logger.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseRuntimeConfigAutoRefresh extends ConsumerStatefulWidget {
  const FirebaseRuntimeConfigAutoRefresh({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<FirebaseRuntimeConfigAutoRefresh> createState() =>
      _FirebaseRuntimeConfigAutoRefreshState();
}

class _FirebaseRuntimeConfigAutoRefreshState
    extends ConsumerState<FirebaseRuntimeConfigAutoRefresh>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshRuntimeConfigIfDue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> _refreshRuntimeConfigIfDue() async {
    try {
      final result = await ref
          .read(firebaseRuntimeConfigControllerProvider.notifier)
          .refreshFromRemoteConfigIfDue();

      if (result == null) {
        return;
      }

      await ref
          .read(analyticsPreferencesProvider.notifier)
          .syncToAnalyticsService();
    } catch (error, stackTrace) {
      Logger.error(
        'Failed to auto-refresh Firebase runtime config on app resume.',
        error,
        stackTrace,
      );
    }
  }
}
