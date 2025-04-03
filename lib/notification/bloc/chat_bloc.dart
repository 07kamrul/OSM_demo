import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) {
    FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs.map((doc) => doc.data()).toList();
      emit(ChatLoaded(messages: messages));
    });
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) {
    FirebaseFirestore.instance.collection('messages').add({
      'sender': event.sender,
      'receiver': event.receiver,
      'message': event.message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
