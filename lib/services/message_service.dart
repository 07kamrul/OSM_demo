// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../data/models/message.dart';
//
// class MessageService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   // Get the messages stream in real-time
//   Stream<List<Message>> getMessages(String chatRoomId) {
//     return _db
//         .collection('chat_rooms')
//         .doc(chatRoomId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
//     });
//   }
//
//   // Send a message
//   Future<void> sendMessage(String chatRoomId, Message message) async {
//     await _db
//         .collection('chat_rooms')
//         .doc(chatRoomId)
//         .collection('messages')
//         .add(message.toMap());
//   }
// }
