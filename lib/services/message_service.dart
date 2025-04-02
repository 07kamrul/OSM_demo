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
}
