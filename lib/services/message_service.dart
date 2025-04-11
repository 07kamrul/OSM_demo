import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/models/message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(int receiverId, String content, int senderId) async {
    try {
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        sentAt: DateTime.now(),
        isRead: false,
      );
      await _firestore
          .collection('message')
          .doc(message.id)
          .set(message.toJson());
    } catch (e) {
      if (kDebugMode) print('Error sending message: $e');
      rethrow;
    }
  }

  Future<List<Message>> getInitialMessages(int senderId, int receiverId) async {
    try {
      final snapshot = await _firestore
          .collection('message')
          .where(Filter.or(
            Filter.and(Filter('senderId', isEqualTo: senderId),
                Filter('receiverId', isEqualTo: receiverId)),
            Filter.and(Filter('senderId', isEqualTo: receiverId),
                Filter('receiverId', isEqualTo: senderId)),
          ))
          .orderBy('sentAt', descending: true)
          .limit(20)
          .get();
      return snapshot.docs
          .map((doc) => Message.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching initial messages: $e');
      return [];
    }
  }

  Stream<List<Message>> getMessages(int senderId, int receiverId) {
    try {
      return _firestore
          .collection('message')
          .where(Filter.or(
            Filter.and(Filter('senderId', isEqualTo: senderId),
                Filter('receiverId', isEqualTo: receiverId)),
            Filter.and(Filter('senderId', isEqualTo: receiverId),
                Filter('receiverId', isEqualTo: senderId)),
          ))
          .orderBy('sentAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Message.fromJson(doc.data()..['id'] = doc.id))
              .toList());
    } catch (e) {
      if (kDebugMode) print('Error setting up message stream: $e');
      return Stream.value([]);
    }
  }

  Future<void> updateMessages(List<Message> messages) async {
    try {
      final batch = _firestore.batch();
      for (var message in messages) {
        batch.update(_firestore.collection('message').doc(message.id),
            {'isRead': message.isRead});
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) print('Error updating messages: $e');
      rethrow;
    }
  }

  Stream<Map<int, List<Message>>> getAllMessages(int currentUserId) {
    try {
      return _firestore
          .collection('message')
          .where(Filter.or(Filter('senderId', isEqualTo: currentUserId),
              Filter('receiverId', isEqualTo: currentUserId)))
          .orderBy('sentAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final messages = snapshot.docs
            .map((doc) => Message.fromJson(doc.data()..['id'] = doc.id))
            .toList();
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
      if (kDebugMode) print('Error fetching all messages: $e');
      return Stream.value({});
    }
  }

  Future<Map<int, List<Message>>> getInitialAllMessages(
      int currentUserId) async {
    try {
      final snapshot = await _firestore
          .collection('message')
          .where(Filter.or(Filter('senderId', isEqualTo: currentUserId),
              Filter('receiverId', isEqualTo: currentUserId)))
          .orderBy('sentAt', descending: true)
          .limit(50)
          .get();

      final messages = snapshot.docs
          .map((doc) => Message.fromJson(doc.data()..['id'] = doc.id))
          .toList();
      Map<int, List<Message>> groupedMessages = {};
      for (var message in messages) {
        int otherUserId = message.senderId == currentUserId
            ? message.receiverId
            : message.senderId;
        groupedMessages.putIfAbsent(otherUserId, () => []).add(message);
      }
      return groupedMessages;
    } catch (e) {
      if (kDebugMode) print('Error fetching initial all messages: $e');
      return {};
    }
  }
}
