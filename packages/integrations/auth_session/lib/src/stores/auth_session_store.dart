import '../models/auth_session_model.dart';

abstract class AuthSessionStore {
  Future<AuthSession> readSession();
  Stream<AuthSession> watchSession();
  Future<void> saveSession(AuthSession session);
  Future<void> clearSession();
}
