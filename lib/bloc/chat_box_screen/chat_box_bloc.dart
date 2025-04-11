import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../data/models/message.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/message_service.dart';
import '../../common/user_storage.dart';
import '../chat_screen/chat_screen_event.dart';

part 'chat_box_event.dart';
part 'chat_box_state.dart';

class ChatBoxBloc extends Bloc<ChatBoxEvent, ChatBoxState> {
  final MessageService _messageService;
  final AuthRepository _authRepository;
  StreamSubscription<Map<int, List<Message>>>? _messageSubscription;

  ChatBoxBloc(this._messageService, this._authRepository)
      : super(ChatBoxInitial()) {
    on<LoadChatBox>(_onLoadChatBox);
    on<ChangeFilter>(_onChangeFilter);
    on<UpdateMessages>(_onUpdateMessages); // New event for stream updates
  }

  Future<void> _onLoadChatBox(
      LoadChatBox event, Emitter<ChatBoxState> emit) async {
    emit(ChatBoxLoading());
    try {
      final int? currentUserId = await UserStorage.getUserId();
      if (currentUserId == null) {
        emit(const ChatBoxError('User ID not found'));
        return;
      }

      // Fetch initial grouped messages synchronously for speed
      final initialMessages =
          await _messageService.getInitialAllMessages(currentUserId);
      final groupedMessages =
          await _processGroupedMessages(initialMessages, currentUserId);

      emit(ChatBoxLoaded(
        currentUserId: currentUserId,
        groupedMessages: groupedMessages,
        filter: 'All',
      ));

      // Cancel any existing subscription before setting up a new one
      _messageSubscription?.cancel();
      _messageSubscription = _messageService
          .getAllMessages(currentUserId)
          .listen((updatedMessages) {
        add(UpdateMessages(updatedMessages)); // Trigger update event
      });
    } catch (e) {
      emit(ChatBoxError('Failed to load messages: $e'));
    }
  }

  Future<void> _onChangeFilter(
      ChangeFilter event, Emitter<ChatBoxState> emit) async {
    if (state is ChatBoxLoaded) {
      final currentState = state as ChatBoxLoaded;
      final filteredMessages =
          _applyFilter(currentState.groupedMessages, event.filter);
      emit(currentState.copyWith(
          filter: event.filter, filteredGroupedMessages: filteredMessages));
    }
  }

  Future<void> _onUpdateMessages(
      UpdateMessages event, Emitter<ChatBoxState> emit) async {
    if (state is ChatBoxLoaded) {
      final currentState = state as ChatBoxLoaded;
      final updatedGroupedMessages = await _processGroupedMessages(
          event.messages, currentState.currentUserId);
      final filteredMessages =
          _applyFilter(updatedGroupedMessages, currentState.filter);
      emit(currentState.copyWith(
        groupedMessages: updatedGroupedMessages,
        filteredGroupedMessages: filteredMessages,
      ));
    }
  }

  Future<Map<int, UserMessages>> _processGroupedMessages(
    Map<int, List<Message>> groupedMessages,
    int currentUserId,
  ) async {
    final Map<int, UserMessages> result = {};
    for (final receiverId in groupedMessages.keys) {
      final messages = groupedMessages[receiverId]!;
      final user = await _authRepository.getUser(receiverId);
      if (user != null) {
        result[receiverId] = UserMessages(user: user, messages: messages);
      }
    }
    return result;
  }

  Map<int, UserMessages> _applyFilter(
      Map<int, UserMessages> groupedMessages, String filter) {
    if (filter == 'All') return groupedMessages;
    if (filter == 'Unread') {
      return Map.from(groupedMessages)
        ..removeWhere(
            (_, userMessages) => userMessages.messages.every((m) => m.isRead));
    }
    return groupedMessages; // Add more filters (e.g., Groups, Favorites) as needed
  }

  @override
  Future<void> close() {
    _messageSubscription
        ?.cancel(); // Cancel the subscription when the BLoC is closed
    return super.close();
  }
}

class UserMessages {
  final User user;
  final List<Message> messages;

  UserMessages({required this.user, required this.messages});

  UserMessages copyWith({User? user, List<Message>? messages}) {
    return UserMessages(
      user: user ?? this.user,
      messages: messages ?? this.messages,
    );
  }
}
