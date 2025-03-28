import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gis_osm/data/models/message.dart';

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Message>> getMessages(int senderId, int receiverId) {
    return _firestore
        .collection('message')
        .where('senderId', whereIn: [senderId, receiverId])
        .where('receiverId', whereIn: [senderId, receiverId])
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> sendMessage(Message message) async {
    await _firestore.collection('message').add(message.toFirestore());
  }

  Future<void> markMessageAsRead(String messageId) async {
    await _firestore
        .collection('message')
        .doc(messageId)
        .update({'isRead': true});
  }
}
