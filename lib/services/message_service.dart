import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/models/message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(int receiverId, String content, int senderId) async {
    try {
      await _firestore.collection('message').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'sentAt': Timestamp.now(),
        'isRead': false,
      });
    } catch (e) {
      print('Error fetching messages: $e');
      // Retry after delay
      Future.delayed(Duration(seconds: 2),
          () => sendMessage(receiverId, content, senderId));
      rethrow; // Let StreamBuilder handle the error
    }
  }

  Stream<List<Message>> getMessages(int senderId, int receiverId) {
    try {
      return _firestore
          .collection('message')
          .where('senderId', whereIn: [senderId, receiverId])
          .where('receiverId', whereIn: [senderId, receiverId])
          .orderBy('sentAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Message.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      print('Error fetching messages: $e');
      // Retry after delay
      Future.delayed(
          Duration(seconds: 2), () => getMessages(senderId, receiverId));
      rethrow; // Let StreamBuilder handle the error
    }
  }

  Stream<Map<int, List<Message>>> getAllMessages(int currentUserId) {
    try {
      return _firestore
          .collection('message')
          .where(
            Filter.or(
              Filter('senderId', isEqualTo: currentUserId),
              Filter('receiverId', isEqualTo: currentUserId),
            ),
          )
          .orderBy('sentAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final messages = snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList();

        // Group messages by chat partner (other user)
        Map<int, List<Message>> groupedMessages = {};
        for (var message in messages) {
          int otherUserId = message.senderId == currentUserId
              ? message.receiverId
              : message.senderId;

          groupedMessages.putIfAbsent(otherUserId, () => []).add(message);
        }

        return groupedMessages;
      });
    } catch (e) {
      print('Error fetching messages: $e');
      // Retry after delay
      Future.delayed(Duration(seconds: 2), () => getAllMessages(currentUserId));
      rethrow; // Let StreamBuilder handle the error
    }
  }

  Future<void> updateMessages(List<Message> messages) async {
    try {
      final batch = _firestore.batch();

      for (var message in messages) {
        final docRef = _firestore.collection('message').doc(message.id);
        batch.update(docRef, {
          'senderId': message.senderId,
          'receiverId': message.receiverId,
          'content': message.content,
          'sentAt': message.sentAt,
          'isRead': true,
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error updating messages: $e');
      // Optional: Retry logic if needed
      rethrow;
    }
  }

  //----------------------------------------------
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((token) {
      print('Firebase Messaging Token: $token');
    }).catchError((error) {
      print('Error getting Firebase Messaging token: $error');
    });
  }
}
