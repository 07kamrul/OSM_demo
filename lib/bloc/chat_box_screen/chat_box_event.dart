part of 'chat_box_bloc.dart';

abstract class ChatBoxEvent extends Equatable {
  const ChatBoxEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatBox extends ChatBoxEvent {}

class ChangeFilter extends ChatBoxEvent {
  final String filter;

  const ChangeFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class UpdateMessages extends ChatBoxEvent {
  final Map<int, List<Message>> messages;

  const UpdateMessages(this.messages);

  @override
  List<Object?> get props => [messages];
}
