import 'package:app_logger/app_logger.dart';
import 'package:collection_tracker/core/observability/operational_telemetry.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncAutoRetryOnResume extends ConsumerStatefulWidget {
  const SyncAutoRetryOnResume({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SyncAutoRetryOnResume> createState() =>
      _SyncAutoRetryOnResumeState();
}

class _SyncAutoRetryOnResumeState extends ConsumerState<SyncAutoRetryOnResume>
    with WidgetsBindingObserver {
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptAutoRetry(trigger: 'app_start');
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
      // Wait briefly so runtime config refresh can settle first.
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        _attemptAutoRetry(trigger: 'resume');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> _attemptAutoRetry({required String trigger}) async {
    if (_isRunning || !mounted) {
      return;
    }

    _isRunning = true;
    try {
      final readiness = ref.read(syncReadinessProvider);
      if (!readiness.isReady) {
        return;
      }

      final pendingBefore = await ref
          .read(syncOrchestratorProvider)
          .getPendingOperationCount();
      if (pendingBefore <= 0) {
        return;
      }

      final syncState = await ref.read(syncDaoProvider).getSyncState();
      final nextRetryAt = syncState?.nextRetryAt?.toUtc();
      if (nextRetryAt == null || DateTime.now().toUtc().isBefore(nextRetryAt)) {
        return;
      }

      final session = ref.read(authSessionProvider).asData?.value;
      final deviceId = session?.deviceId;
      if (deviceId == null || deviceId.trim().isEmpty) {
        return;
      }

      await OperationalTelemetry.trackSyncAttempt(
        trigger: 'auto_retry_$trigger',
        readinessStatus: readiness.status.name,
        pendingBefore: pendingBefore,
      );

      final result = await ref
          .read(syncOrchestratorProvider)
          .syncNow(deviceId: deviceId);
      await OperationalTelemetry.trackSyncResult(
        success: result.success,
        executed: result.executed,
        partial: result.partial,
        pendingOperations: result.pendingOperations,
        processedOperations: result.processedOperations,
        syncedCollections: result.syncedCollections,
        syncedItems: result.syncedItems,
        syncedTags: result.syncedTags,
        syncedLoans: result.syncedLoans,
        conflictCount: result.conflictCount,
        appliedServerCollections: result.appliedServerCollections,
        appliedServerItems: result.appliedServerItems,
        appliedServerTags: result.appliedServerTags,
        appliedServerLoans: result.appliedServerLoans,
        skippedServerCollections: result.skippedServerCollections,
        skippedServerItems: result.skippedServerItems,
        skippedServerTags: result.skippedServerTags,
        skippedServerLoans: result.skippedServerLoans,
        message: result.message,
        error: result.error,
        stackTrace: result.stackTrace,
      );
    } catch (error, stackTrace) {
      Logger.error(
        'Failed to auto-retry sync on lifecycle event.',
        error,
        stackTrace,
      );
    } finally {
      _isRunning = false;
    }
  }
}
