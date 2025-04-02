import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(int receiverId, String content, int senderId) async {
    await _firestore.collection('message').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'sentAt': Timestamp.now(),
      'isRead': false,
    });
  }

  Stream<List<Message>> getMessages(int senderId, int receiverId) {
    return _firestore
        .collection('message')
        .where('senderId', whereIn: [senderId])
        .where('receiverId', whereIn: [receiverId])
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<Map<int, List<Message>>> getAllMessages(int currentUserId) {
    return _firestore
        .collection('message')
        .where('senderId', isEqualTo: currentUserId) // Fetch only sent messages
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map(
            (doc) => Message.fromMap(doc.data(), doc.id),
          )
          .toList();

      // Group messages by receiverId
      Map<int, List<Message>> groupedMessages = {};
      for (var message in messages) {
        groupedMessages.putIfAbsent(message.receiverId, () => []).add(message);
      }

      return groupedMessages;
    });
  }
}
