class FirebaseMessagingMessage {
  const FirebaseMessagingMessage({
    required this.data,
    this.messageId,
    this.title,
    this.body,
    this.sentTime,
  });

  final String? messageId;
  final String? title;
  final String? body;
  final DateTime? sentTime;
  final Map<String, String> data;
}
