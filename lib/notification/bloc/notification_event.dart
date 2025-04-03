import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Listen for incoming messages
class ListenForMessages extends NotificationEvent {}

// Handle foreground notifications
class MessageReceived extends NotificationEvent {
  final RemoteMessage message;

  MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
