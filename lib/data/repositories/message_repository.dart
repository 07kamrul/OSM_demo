import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gis_osm/data/models/message.dart';

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for messages
  CollectionReference get _messagesCollection =>
      _firestore.collection('messages');

  // Stream of messages between two users (real-time)
  Stream<List<Message>> getMessages(int senderId, int receiverId) {
    try {
      return _messagesCollection
          .where('senderId', whereIn: [senderId, receiverId])
          .where('receiverId', whereIn: [senderId, receiverId])
          .orderBy('sentAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map(
                  (doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  // Mark a message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _messagesCollection.doc(messageId).update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }
}
