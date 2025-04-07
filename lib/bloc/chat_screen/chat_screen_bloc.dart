import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibration/vibration.dart';
import '../../data/models/message.dart';
import '../../data/models/user.dart';
import '../../data/repositories/message_repository.dart';
import '../../services/message_service.dart';
import '../../services/user_service.dart';
import 'chat_screen_event.dart';
import 'chat_screen_state.dart';

class ChatScreenBloc extends Bloc<ChatScreenEvent, ChatScreenState> {
  final MessageService _messageService;
  final MessageRepository _messageRepository;
  final UserService _userService;
  final int senderId;
  final int receiverId;
  final AudioPlayer _audioPlayer = AudioPlayer();

  ChatScreenBloc(this._messageService, this._messageRepository,
      this._userService, this.senderId, this.receiverId)
      : super(ChatInitial()) {
    on<LoadChat>(_onLoadChat);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<PickImage>(_onPickImage);
  }

  Future<void> _onLoadChat(
      LoadChat event, Emitter<ChatScreenState> emit) async {
    emit(ChatLoading());
    try {
      final user = await _userService.fetchUserInfo(event.receiverId);
      final messagesStream =
          _messageService.getMessages(event.senderId, event.receiverId);
      await for (var messages in messagesStream) {
        final incomingMessages = messages
            .where((m) => m.receiverId == senderId && !(m.isRead ?? false))
            .toList();
        String? lastMessageId =
            state is ChatLoaded ? (state as ChatLoaded).lastMessageId : null;

        if (incomingMessages.isNotEmpty &&
            lastMessageId != incomingMessages.first.id) {
          lastMessageId = incomingMessages.first.id;
          if (await Vibration.hasVibrator() ?? false) {
            Vibration.vibrate(duration: 500);
          }
          try {
            await _audioPlayer.play(AssetSource('notification.wav'));
          } catch (e) {
            if (kDebugMode) print('Error playing sound: $e');
          }
          add(MarkMessagesAsRead());
        }
        emit(ChatLoaded(messages, user, lastMessageId));
      }
    } catch (e) {
      emit(ChatError('Failed to load chat: $e'));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatScreenState> emit) async {
    if (event.content.isNotEmpty) {
      try {
        await _messageService.sendMessage(receiverId, event.content, senderId);
        // No need to manually update state; stream will handle it
      } catch (e) {
        emit(ChatError('Failed to send message: $e'));
      }
    }
  }

  Future<void> _onMarkMessagesAsRead(
      MarkMessagesAsRead event, Emitter<ChatScreenState> emit) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final unread = currentState.messages
          .where((m) => !(m.isRead ?? false) && m.receiverId == senderId)
          .toList();
      if (unread.isNotEmpty) {
        try {
          await _messageService.updateMessages(
              unread.map((m) => m.copyWith(isRead: true)).toList());
          // Stream will update the UI
        } catch (e) {
          emit(ChatError('Failed to mark messages as read: $e'));
        }
      }
    }
  }

  Future<void> _onPickImage(
      PickImage event, Emitter<ChatScreenState> emit) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: event.source);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final imageUrl = await _uploadImage(imageFile);
        if (imageUrl != null) {
          await _messageService.sendMessage(receiverId, imageUrl, senderId);
          // Stream will update the UI
        }
      }
    } catch (e) {
      emit(ChatError('Failed to pick image: $e'));
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    if (kDebugMode) print('Uploading image: ${imageFile.path}');
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com/uploaded_image.jpg';
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
