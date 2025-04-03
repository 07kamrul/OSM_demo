import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class ChatInitial extends ChatState {}

// State when messages are loaded
class ChatLoaded extends ChatState {
  final List<Map<String, dynamic>> messages;

  ChatLoaded({required this.messages});

  @override
  List<Object?> get props => [messages];
}
