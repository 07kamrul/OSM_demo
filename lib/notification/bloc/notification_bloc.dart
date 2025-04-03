import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationBloc() : super(NotificationInitial()) {
    on<ListenForMessages>(_onListenForMessages);
    on<MessageReceived>(_onMessageReceived);

    _initializeLocalNotifications();
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    _localNotifications.initialize(initSettings);
  }

  void _onListenForMessages(
      ListenForMessages event, Emitter<NotificationState> emit) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      add(MessageReceived(message));
    });
  }

  void _onMessageReceived(
      MessageReceived event, Emitter<NotificationState> emit) {
    final notification = event.message.notification;
    if (notification != null) {
      _showLocalNotification(notification.title ?? "New Message",
          notification.body ?? "You have a new message");

      emit(NotificationReceived(
          title: notification.title ?? "New Message",
          body: notification.body ?? "You have a new message"));
    }
  }

  void _showLocalNotification(String title, String body) {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 1000, 1500]),
    );

    NotificationDetails details = NotificationDetails(android: androidDetails);

    _localNotifications.show(0, title, body, details);
  }
}
