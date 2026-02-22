import 'package:collection_tracker/core/observability/operational_telemetry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final operationalTelemetryRefreshTokenProvider =
    NotifierProvider<OperationalTelemetryRefreshTokenNotifier, int>(
      OperationalTelemetryRefreshTokenNotifier.new,
    );

class OperationalTelemetryRefreshTokenNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() {
    state = state + 1;
  }
}

final operationalTelemetryHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      ref.watch(operationalTelemetryRefreshTokenProvider);
      return OperationalTelemetry.loadRecentHistory(limit: 80);
    });

Future<void> refreshOperationalTelemetryHistory(WidgetRef ref) async {
  ref.read(operationalTelemetryRefreshTokenProvider.notifier).bump();
  await ref.read(operationalTelemetryHistoryProvider.future);
}

Future<void> clearOperationalTelemetryHistory(WidgetRef ref) async {
  await OperationalTelemetry.clearHistory();
  ref.read(operationalTelemetryRefreshTokenProvider.notifier).bump();
}
