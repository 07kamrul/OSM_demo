import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id; // Document ID from Firestore
  final String content;
  final bool isRead;
  final int receiverId;
  final int senderId;
  final Timestamp sentAt;

  Message({
    required this.id,
    required this.content,
    required this.isRead,
    required this.receiverId,
    required this.senderId,
    required this.sentAt,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      content: data['content'] ?? '',
      isRead: data['isRead'] ?? false,
      receiverId: data['receiverId'] ?? 0,
      senderId: data['senderId'] ?? 0,
      sentAt: data['sentAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'isRead': isRead,
      'receiverId': receiverId,
      'senderId': senderId,
      'sentAt': sentAt,
    };
  }
}
