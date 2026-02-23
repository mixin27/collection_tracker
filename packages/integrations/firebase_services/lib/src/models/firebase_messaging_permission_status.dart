enum FirebaseMessagingPermissionStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
  unsupported,
}

extension FirebaseMessagingPermissionStatusX
    on FirebaseMessagingPermissionStatus {
  bool get isGranted =>
      this == FirebaseMessagingPermissionStatus.authorized ||
      this == FirebaseMessagingPermissionStatus.provisional;
}
