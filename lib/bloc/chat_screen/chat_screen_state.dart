import 'package:equatable/equatable.dart';
import '../../data/models/message.dart';
import '../../data/models/user.dart';

abstract class ChatScreenState extends Equatable {
  const ChatScreenState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatScreenState {}

class ChatLoading extends ChatScreenState {}

class ChatLoaded extends ChatScreenState {
  final List<Message> messages;
  final User receiver;
  final String? lastMessageId;

  const ChatLoaded(this.messages, this.receiver, this.lastMessageId);

  @override
  List<Object?> get props => [messages, receiver, lastMessageId];
}

class ChatError extends ChatScreenState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
