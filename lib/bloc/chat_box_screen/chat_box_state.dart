part of 'chat_box_bloc.dart';

abstract class ChatBoxState extends Equatable {
  const ChatBoxState();

  @override
  List<Object?> get props => [];
}

class ChatBoxInitial extends ChatBoxState {}

class ChatBoxLoading extends ChatBoxState {}

class ChatBoxLoaded extends ChatBoxState {
  final int currentUserId;
  final Map<int, UserMessages> groupedMessages;
  final String filter;
  final Map<int, UserMessages> filteredGroupedMessages;

  const ChatBoxLoaded({
    required this.currentUserId,
    required this.groupedMessages,
    required this.filter,
    Map<int, UserMessages>? filteredGroupedMessages,
  }) : filteredGroupedMessages = filteredGroupedMessages ?? groupedMessages;

  ChatBoxLoaded copyWith({
    int? currentUserId,
    Map<int, UserMessages>? groupedMessages,
    String? filter,
    Map<int, UserMessages>? filteredGroupedMessages,
  }) {
    return ChatBoxLoaded(
      currentUserId: currentUserId ?? this.currentUserId,
      groupedMessages: groupedMessages ?? this.groupedMessages,
      filter: filter ?? this.filter,
      filteredGroupedMessages:
          filteredGroupedMessages ?? this.filteredGroupedMessages,
    );
  }

  @override
  List<Object?> get props =>
      [currentUserId, groupedMessages, filter, filteredGroupedMessages];
}

class ChatBoxError extends ChatBoxState {
  final String message;

  const ChatBoxError(this.message);

  @override
  List<Object?> get props => [message];
}
