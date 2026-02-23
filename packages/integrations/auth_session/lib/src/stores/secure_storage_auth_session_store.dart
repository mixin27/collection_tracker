import 'dart:async';

import 'package:storage/storage.dart';

import '../models/auth_session_model.dart';
import 'auth_session_store.dart';

class SecureStorageAuthSessionStore implements AuthSessionStore {
  SecureStorageAuthSessionStore({
    required SecureStorageService storage,
    this.storageKey = 'auth_session_payload',
  }) : _storage = storage;

  final SecureStorageService _storage;
  final String storageKey;
  final StreamController<AuthSession> _controller =
      StreamController<AuthSession>.broadcast();

  @override
  Future<AuthSession> readSession() async {
    final raw = await _storage.get<Map<String, dynamic>>(storageKey);
    if (raw == null) {
      return AuthSession.signedOut();
    }
    return AuthSession.fromJson(raw);
  }

  @override
  Stream<AuthSession> watchSession() async* {
    yield await readSession();
    yield* _controller.stream;
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await _storage.save<Map<String, dynamic>>(storageKey, session.toJson());
    _controller.add(session);
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(storageKey);
    _controller.add(AuthSession.signedOut());
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
