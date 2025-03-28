import 'package:gis_osm/data/models/message.dart';
import 'package:gis_osm/data/repositories/message_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final MessageRepository _messageRepository;

  MessageService({MessageRepository? messageRepository})
      : _messageRepository = messageRepository ?? MessageRepository();

  Stream<List<Message>> getMessages(int senderId, int receiverId) {
    return _messageRepository.getMessages(senderId, receiverId);
  }

  Future<void> sendMessage(int receiverId, String content, int senderId) async {
    final message = Message(
      id: '', // Firestore will auto-generate the ID
      content: content,
      isRead: false,
      receiverId: receiverId,
      senderId: senderId,
      sentAt: Timestamp.now(),
    );
    await _messageRepository.sendMessage(message);
  }
}
