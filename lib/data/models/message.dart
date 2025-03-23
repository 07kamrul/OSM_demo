import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final Timestamp sentAt;
  final bool isRead;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });

  // Factory method to create a Message from Firestore data
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      sentAt: json['sentAt'] is Timestamp ? json['sentAt'] : Timestamp.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  // Convert Message to Firestore-compatible data (Map)
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'sentAt': sentAt,
      'isRead': isRead,
    };
  }
}
