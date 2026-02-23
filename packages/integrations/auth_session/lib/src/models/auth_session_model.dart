enum AuthSessionStatus { signedOut, signedIn }

class AuthSession {
  const AuthSession({
    required this.status,
    this.accessToken,
    this.refreshToken,
    this.deviceId,
    this.userId,
    this.expiresAt,
    required this.updatedAt,
  });

  AuthSession.signedOut({DateTime? updatedAt})
    : status = AuthSessionStatus.signedOut,
      accessToken = null,
      refreshToken = null,
      deviceId = null,
      userId = null,
      expiresAt = null,
      updatedAt = updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  AuthSession.signedIn({
    required this.accessToken,
    required this.refreshToken,
    required this.deviceId,
    this.userId,
    this.expiresAt,
    required this.updatedAt,
  }) : status = AuthSessionStatus.signedIn;

  final AuthSessionStatus status;
  final String? accessToken;
  final String? refreshToken;
  final String? deviceId;
  final String? userId;
  final DateTime? expiresAt;
  final DateTime updatedAt;

  bool get hasAccessToken =>
      accessToken != null && accessToken!.trim().isNotEmpty;

  bool get canRefresh =>
      refreshToken != null &&
      refreshToken!.trim().isNotEmpty &&
      deviceId != null &&
      deviceId!.trim().isNotEmpty;

  bool get isAuthenticated =>
      status == AuthSessionStatus.signedIn && (hasAccessToken || canRefresh);

  AuthSession copyWith({
    AuthSessionStatus? status,
    String? accessToken,
    String? refreshToken,
    String? deviceId,
    String? userId,
    DateTime? expiresAt,
    DateTime? updatedAt,
  }) {
    return AuthSession(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'deviceId': deviceId,
      'userId': userId,
      'expiresAt': expiresAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final statusRaw = json['status'] as String?;
    final status = AuthSessionStatus.values.firstWhere(
      (value) => value.name == statusRaw,
      orElse: () => AuthSessionStatus.signedOut,
    );

    final updatedAt =
        DateTime.tryParse(json['updatedAt'] as String? ?? '')?.toUtc() ??
        DateTime.now().toUtc();

    return AuthSession(
      status: status,
      accessToken: _asNullableString(json['accessToken']),
      refreshToken: _asNullableString(json['refreshToken']),
      deviceId: _asNullableString(json['deviceId']),
      userId: _asNullableString(json['userId']),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '')?.toUtc(),
      updatedAt: updatedAt,
    );
  }

  static String? _asNullableString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
