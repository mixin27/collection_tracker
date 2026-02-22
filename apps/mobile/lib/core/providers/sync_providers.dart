import 'package:collection_tracker/core/providers/database_providers.dart';
import 'package:collection_tracker/core/sync/sync_backend_client.dart';
import 'package:collection_tracker/core/sync/sync_orchestrator.dart';
import 'package:database/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncDaoProvider = Provider<SyncDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database.syncDao;
});

final syncBackendClientProvider = Provider<SyncBackendClient>((ref) {
  return const NoopSyncBackendClient();
});

final syncOrchestratorProvider = Provider<SyncOrchestrator>((ref) {
  final dao = ref.watch(syncDaoProvider);
  final backendClient = ref.watch(syncBackendClientProvider);
  return SyncOrchestrator(syncDao: dao, backendClient: backendClient);
});

final syncOutboxCountProvider = StreamProvider<int>((ref) {
  final dao = ref.watch(syncDaoProvider);
  return dao.watchPendingOperationCount();
});
