import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/message.dart';

abstract class ChatScreenEvent extends Equatable {
  const ChatScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadChat extends ChatScreenEvent {
  final int senderId;
  final int receiverId;

  const LoadChat(this.senderId, this.receiverId);

  @override
  List<Object?> get props => [senderId, receiverId];
}

class SendMessage extends ChatScreenEvent {
  final String content;

  const SendMessage(this.content);

  @override
  List<Object?> get props => [content];
}

class MarkMessagesAsRead extends ChatScreenEvent {
  const MarkMessagesAsRead();
}

class PickImage extends ChatScreenEvent {
  final ImageSource source;

  const PickImage(this.source);

  @override
  List<Object?> get props => [source];
}

class UpdateMessages extends ChatScreenEvent {
  final List<Message> messages;

  const UpdateMessages(this.messages);

  @override
  List<Object?> get props => [messages];
}
