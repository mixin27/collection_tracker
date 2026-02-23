import 'package:auth_session/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';

final authSessionStoreProvider = Provider<AuthSessionStore>((ref) {
  return SecureStorageAuthSessionStore(storage: SecureStorageService.instance);
});

final authSessionProvider = StreamProvider<AuthSession>((ref) {
  final store = ref.watch(authSessionStoreProvider);
  return store.watchSession();
});

final authSessionIsAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(authSessionProvider).value;
  return session?.isAuthenticated ?? false;
});
