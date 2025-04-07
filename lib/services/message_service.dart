import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
          .where(Filter.or(
            Filter.and(
              Filter('senderId', isEqualTo: senderId),
              Filter('receiverId', isEqualTo: receiverId),
            ),
            Filter.and(
              Filter('senderId', isEqualTo: receiverId),
              Filter('receiverId', isEqualTo: senderId),
            ),
          ))
          .orderBy('sentAt', descending: true)
          .snapshots()
          .map((snapshot) {
        try {
          return snapshot.docs.map((doc) {
            try {
              return Message(
                id: doc.id,
                senderId: doc['senderId'] as int,
                receiverId: doc['receiverId'] as int,
                content: doc['content'] as String,
                sentAt: (doc['sentAt'] as Timestamp).toDate(),
                isRead: doc['isRead'] as bool,
              );
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing message document ${doc.id}: $e');
              }
              // Return a fallback message or null, depending on your needs
              return Message(
                id: doc.id,
                senderId: senderId,
                receiverId: receiverId,
                content: 'Error loading message',
                sentAt: DateTime.now(),
                isRead: false,
              );
            }
          }).toList();
        } catch (e) {
          if (kDebugMode) {
            print('Error mapping snapshot to messages: $e');
          }
          rethrow; // Propagate to StreamBuilder
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up message stream: $e');
      }
      // Return a stream with an error state
      return Stream.error('Failed to load messages: $e');
    }
  }

  Future<void> updateMessages(List<Message> messages) async {
    try {
      final batch = _firestore.batch();
      for (var message in messages) {
        try {
          final docRef = _firestore.collection('message').doc(message.id);
          batch.update(docRef, {
            'isRead': message.isRead,
          });
        } catch (e) {
          if (kDebugMode) {
            print('Error preparing batch update for message ${message.id}: $e');
          }
          rethrow; // Fail fast if batch preparation fails
        }
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating messages: $e');
      }
      // Retry logic (optional)
      await Future.delayed(const Duration(seconds: 2));
      try {
        await updateMessages(messages); // Retry once
        if (kDebugMode) {
          print('Retry successful');
        }
      } catch (retryError) {
        if (kDebugMode) {
          print('Retry failed: $retryError');
        }
        rethrow; // Propagate to caller
      }
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
