enum AppUpdateStatus {
  upToDate,
  updateAvailable,
  updateRequired,
  deferred,
  disabled,
  notConfigured,
  error,
}

enum AppUpdateSource { backend, remoteConfig, none }

class AppUpdateResult {
  const AppUpdateResult({
    required this.status,
    required this.source,
    required this.checkedAt,
    required this.currentVersion,
    this.latestVersion,
    this.minSupportedVersion,
    this.title,
    this.message,
    this.storeUrl,
    this.snoozeHours = 24,
    this.errorMessage,
  });

  final AppUpdateStatus status;
  final AppUpdateSource source;
  final DateTime checkedAt;
  final String currentVersion;
  final String? latestVersion;
  final String? minSupportedVersion;
  final String? title;
  final String? message;
  final String? storeUrl;
  final int snoozeHours;
  final String? errorMessage;

  bool get hasUpdate =>
      status == AppUpdateStatus.updateAvailable ||
      status == AppUpdateStatus.updateRequired ||
      status == AppUpdateStatus.deferred;

  bool get isForceUpdate => status == AppUpdateStatus.updateRequired;

  bool get canSnooze =>
      status == AppUpdateStatus.updateAvailable ||
      status == AppUpdateStatus.deferred;

  bool get hasStoreUrl => storeUrl != null && storeUrl!.trim().isNotEmpty;

  String get signature {
    final latest = latestVersion?.trim() ?? '-';
    final minimum = minSupportedVersion?.trim() ?? '-';
    return '$latest|$minimum|${status.name}';
  }

  AppUpdateResult copyWith({
    AppUpdateStatus? status,
    AppUpdateSource? source,
    DateTime? checkedAt,
    String? currentVersion,
    String? latestVersion,
    String? minSupportedVersion,
    String? title,
    String? message,
    String? storeUrl,
    int? snoozeHours,
    String? errorMessage,
  }) {
    return AppUpdateResult(
      status: status ?? this.status,
      source: source ?? this.source,
      checkedAt: checkedAt ?? this.checkedAt,
      currentVersion: currentVersion ?? this.currentVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      minSupportedVersion: minSupportedVersion ?? this.minSupportedVersion,
      title: title ?? this.title,
      message: message ?? this.message,
      storeUrl: storeUrl ?? this.storeUrl,
      snoozeHours: snoozeHours ?? this.snoozeHours,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AppUpdateState {
  const AppUpdateState({
    this.isChecking = false,
    this.lastResult,
    this.lastCheckAt,
    this.errorMessage,
  });

  final bool isChecking;
  final AppUpdateResult? lastResult;
  final DateTime? lastCheckAt;
  final String? errorMessage;

  AppUpdateState copyWith({
    bool? isChecking,
    AppUpdateResult? lastResult,
    DateTime? lastCheckAt,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AppUpdateState(
      isChecking: isChecking ?? this.isChecking,
      lastResult: lastResult ?? this.lastResult,
      lastCheckAt: lastCheckAt ?? this.lastCheckAt,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
