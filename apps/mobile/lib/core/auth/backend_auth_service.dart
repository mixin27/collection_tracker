import 'dart:io';

import 'package:auth_session/auth_session.dart';
import 'package:backend_api/backend_api.dart';

class BackendAuthService {
  BackendAuthService({
    required BackendAuthClient client,
    required AuthSessionStore sessionStore,
    required Future<String> Function() resolveDeviceId,
    this.appVersion = '1.0.0',
  }) : _client = client,
       _sessionStore = sessionStore,
       _resolveDeviceId = resolveDeviceId;

  final BackendAuthClient _client;
  final AuthSessionStore _sessionStore;
  final Future<String> Function() _resolveDeviceId;
  final String appVersion;

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final deviceId = await _resolveDeviceId();
    final response = await _client.login(
      BackendLoginRequest(
        email: email,
        password: password,
        deviceId: deviceId,
        deviceName: _deviceName(),
        deviceOs: _deviceOs(),
        appVersion: appVersion,
      ),
    );

    return _persistAuthResponse(response);
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final deviceId = await _resolveDeviceId();
    final response = await _client.register(
      BackendRegisterRequest(
        email: email,
        password: password,
        displayName: displayName,
        deviceId: deviceId,
        deviceName: _deviceName(),
        deviceOs: _deviceOs(),
        appVersion: appVersion,
      ),
    );

    return _persistAuthResponse(response);
  }

  Future<AuthSession?> refreshSession() async {
    final existing = await _sessionStore.readSession();
    if (!existing.canRefresh || existing.refreshToken == null) {
      return null;
    }

    try {
      final tokens = await _client.refresh(
        BackendRefreshTokenRequest(
          refreshToken: existing.refreshToken!,
          deviceId: existing.deviceId!,
        ),
      );

      final updated = existing.copyWith(
        status: AuthSessionStatus.signedIn,
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        updatedAt: DateTime.now().toUtc(),
      );

      await _sessionStore.saveSession(updated);
      return updated;
    } on BackendApiException catch (error) {
      final statusCode = error.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        await _sessionStore.clearSession();
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    final existing = await _sessionStore.readSession();

    if (existing.hasAccessToken && existing.accessToken != null) {
      try {
        await _client.logout(existing.accessToken!);
      } on BackendApiException {
        // Always clear local session even if remote logout fails.
      }
    }

    await _sessionStore.clearSession();
  }

  Future<BackendAuthUser?> fetchProfile() async {
    final existing = await _sessionStore.readSession();
    if (!existing.hasAccessToken || existing.accessToken == null) {
      return null;
    }

    final response = await _client.me(existing.accessToken!);
    return response.user;
  }

  Future<void> requestAccountDeletion({String? reason}) async {
    final existing = await _sessionStore.readSession();
    if (!existing.hasAccessToken || existing.accessToken == null) {
      throw const BackendApiException(
        message: 'Sign in is required to request account deletion.',
        code: 'AUTH_REQUIRED',
      );
    }

    await _client.requestAccountDeletion(
      accessToken: existing.accessToken!,
      request: BackendAccountDeletionRequest(
        reason: reason,
        source: 'mobile_app',
      ),
    );

    await _sessionStore.clearSession();
  }

  Future<AuthSession> _persistAuthResponse(BackendAuthResponse response) async {
    final session = AuthSession(
      status: AuthSessionStatus.signedIn,
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      deviceId: response.session.deviceId,
      userId: response.user.id,
      expiresAt: response.session.expiresAt,
      updatedAt: DateTime.now().toUtc(),
    );

    await _sessionStore.saveSession(session);
    return session;
  }

  String _deviceName() {
    final host = Platform.localHostname.trim();
    if (host.isNotEmpty) {
      return host;
    }
    return 'Mobile Device';
  }

  String _deviceOs() {
    final os = Platform.operatingSystem.trim();
    final version = Platform.operatingSystemVersion.trim();
    return '$os $version'.trim();
  }
}
