import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigStatus {
  const FirebaseRemoteConfigStatus({
    required this.isInitialized,
    required this.lastFetchTime,
    required this.lastFetchStatus,
  });

  final bool isInitialized;
  final DateTime? lastFetchTime;
  final RemoteConfigFetchStatus? lastFetchStatus;
}
