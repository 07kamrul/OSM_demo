class Message {
  final String messageId; // Changed to String for Firebase document ID
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });

  // Factory method to create a Message from JSON/Firestore data
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'] as String? ?? '',
      senderId: json['senderId'] as int? ?? 0,
      receiverId: json['receiverId'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      sentAt: DateTime.parse(
          json['sentAt'] as String? ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  // Convert Message to JSON/Firestore data
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
