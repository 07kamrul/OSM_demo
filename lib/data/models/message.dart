import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message extends Equatable {
  final String id;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });

  Message copyWith({
    String? id,
    int? senderId,
    int? receiverId,
    String? content,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'sentAt': Timestamp.fromDate(sentAt),
        'isRead': isRead,
      };

  static Message fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        senderId: json['senderId'] as int,
        receiverId: json['receiverId'] as int,
        content: json['content'] as String,
        sentAt: (json['sentAt'] as Timestamp).toDate(),
        isRead: json['isRead'] as bool? ?? false, // Default to false if null
      );

  @override
  List<Object?> get props =>
      [id, senderId, receiverId, content, sentAt, isRead];
}
