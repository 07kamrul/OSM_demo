import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/models/message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Message>> getMessages(int senderId, int receiverId) {
    return _firestore
        .collection('message')
        .where('senderId', whereIn: [senderId, receiverId])
        .where('receiverId', whereIn: [senderId, receiverId])
        .orderBy('sentAt', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((snapshot) async {
          return await compute(_parseMessages, snapshot);
        });
  }

  Future<void> sendMessage(int receiverId, String content, int senderId) async {
    await _firestore.collection('message').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'sentAt': Timestamp.now(),
    });
  }
}

// Function to parse Firestore snapshot in a background isolate
List<Message> _parseMessages(QuerySnapshot<Map<String, dynamic>> snapshot) {
  return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
}
