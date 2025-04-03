import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Fetch messages in real-time
class LoadMessages extends ChatEvent {}

// Send a message
class SendMessage extends ChatEvent {
  final String sender;
  final String receiver;
  final String message;

  SendMessage(
      {required this.sender, required this.receiver, required this.message});

  @override
  List<Object?> get props => [sender, receiver, message];
}
