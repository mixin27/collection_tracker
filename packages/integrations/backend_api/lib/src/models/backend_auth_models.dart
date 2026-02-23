class BackendAuthUser {
  const BackendAuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.subscriptionTier,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String subscriptionTier;

  factory BackendAuthUser.fromJson(Map<String, dynamic> json) {
    return BackendAuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      subscriptionTier: json['subscriptionTier'] as String? ?? 'FREE',
    );
  }
}

class BackendSessionInfo {
  const BackendSessionInfo({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.expiresAt,
  });

  final String id;
  final String deviceId;
  final String deviceName;
  final DateTime? expiresAt;

  factory BackendSessionInfo.fromJson(Map<String, dynamic> json) {
    return BackendSessionInfo(
      id: json['id'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      deviceName: json['deviceName'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '')?.toUtc(),
    );
  }
}

class BackendAuthResponse {
  const BackendAuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.session,
  });

  final String accessToken;
  final String refreshToken;
  final BackendAuthUser user;
  final BackendSessionInfo session;

  factory BackendAuthResponse.fromJson(Map<String, dynamic> json) {
    final userJson =
        (json['user'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final sessionJson =
        (json['session'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    return BackendAuthResponse(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: BackendAuthUser.fromJson(userJson),
      session: BackendSessionInfo.fromJson(sessionJson),
    );
  }
}

class BackendTokenPair {
  const BackendTokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory BackendTokenPair.fromJson(Map<String, dynamic> json) {
    return BackendTokenPair(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}

class BackendProfileResponse {
  const BackendProfileResponse({required this.user});

  final BackendAuthUser user;

  factory BackendProfileResponse.fromJson(Map<String, dynamic> json) {
    final userJson =
        (json['user'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return BackendProfileResponse(user: BackendAuthUser.fromJson(userJson));
  }
}

class BackendRegisterRequest {
  const BackendRegisterRequest({
    required this.email,
    required this.password,
    required this.deviceId,
    required this.deviceName,
    required this.deviceOs,
    this.displayName,
    this.appVersion,
  });

  final String email;
  final String password;
  final String? displayName;
  final String deviceId;
  final String deviceName;
  final String deviceOs;
  final String? appVersion;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'displayName': displayName,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceOs': deviceOs,
      'appVersion': appVersion,
    };
  }
}

class BackendLoginRequest {
  const BackendLoginRequest({
    required this.email,
    required this.password,
    required this.deviceId,
    required this.deviceName,
    required this.deviceOs,
    this.appVersion,
  });

  final String email;
  final String password;
  final String deviceId;
  final String deviceName;
  final String deviceOs;
  final String? appVersion;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceOs': deviceOs,
      'appVersion': appVersion,
    };
  }
}

class BackendRefreshTokenRequest {
  const BackendRefreshTokenRequest({
    required this.refreshToken,
    required this.deviceId,
  });

  final String refreshToken;
  final String deviceId;

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken, 'deviceId': deviceId};
  }
}
