import 'dart:ui';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gis_osm/common/user_storage.dart';
import 'package:gis_osm/data/repositories/auth_repository.dart';
import 'package:gis_osm/services/message_service.dart';
import 'package:gis_osm/screen/message_screens/chat_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'message_channel',
  'Messages',
  description: 'This channel is for message notifications',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp().timeout(Duration(seconds: 3));
    print('Background message received: ${message.notification?.title}');
    await _showNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? 'You have a new message',
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  } catch (e) {
    print('Firebase background init error: $e');
  }
}

Future<void> initializeService(BuildContext context) async {
  final service = FlutterBackgroundService();

  final isRunning = await service.isRunning();
  if (!isRunning) {
    // Configure before starting
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        onStart: onStart,
        isForegroundMode: true,
        autoStartOnBoot: false,
        initialNotificationTitle: 'Notification Service',
        initialNotificationContent: 'Running in background',
        foregroundServiceNotificationId: 888,
      ),
    );

    await service.startService(); // ✅ Only start once
  }

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) async {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        final senderId = int.tryParse(data['senderId'] ?? '');
        final receiverId = int.tryParse(data['receiverId'] ?? '');
        if (senderId != null && receiverId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                senderId: senderId,
                receiverId: receiverId,
                route: 1,
              ),
            ),
          );
        }
      }
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  print('Service initialized ✅');
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    await service.setForegroundNotificationInfo(
      title: 'Notification Service',
      content: 'Running in background',
    );
    print('Foreground notification set ✅');
  }

  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  try {
    await Firebase.initializeApp().timeout(Duration(seconds: 3));
    print('Firebase initialized in background');
  } catch (e) {
    print('Error initializing Firebase in background: $e');
    return;
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground message received: ${message.notification?.title}');
    _showNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? 'You have a new message',
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  });

  final userId = await UserStorage.getUserId();
  if (userId != null) {
    _setupMessageStreamListener(userId);
  } else {
    print('User ID is null in background service');
  }

  service.on("stopService").listen((event) {
    print("Stopping background service");
    service.stopSelf();
  });
}

void _setupMessageStreamListener(int userId) {
  final messageService = MessageService();
  final authRepository = AuthRepository();
  final currentUserMessagesStream = messageService.getAllMessages(userId);
  currentUserMessagesStream.listen((allMessagesMap) async {
    final allMessages = allMessagesMap.values.expand((list) => list).toList();
    final receivedMessages = allMessages
        .where((message) =>
            message.receiverId == userId &&
            userId != message.senderId &&
            !message.isRead)
        .toList();
    if (receivedMessages.isNotEmpty) {
      for (var message in receivedMessages) {
        print('New unread message in background: ${message.content}');
        final receiverInfo = await authRepository.getUser(message.senderId);
        await _showNotification(
          title: '${receiverInfo.fullname} Sent a Message',
          body: message.content,
          payload: jsonEncode({
            'senderId': message.senderId.toString(),
            'receiverId': message.receiverId.toString(),
          }),
        );
      }
    }
  }, onError: (error) {
    print('Error in background message stream: $error');
  });
}

Future<void> _showNotification({
  required String title,
  required String body,
  String? payload,
}) async {
  try {
    const androidDetails = AndroidNotificationDetails(
      'message_channel',
      'Messages',
      channelDescription: 'This channel is for message notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      icon: '@mipmap/ic_launcher',
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformDetails,
      payload: payload,
    );
    print('Notification shown: $title - $body');
  } catch (e) {
    print('Error showing notification: $e');
    const fallbackDetails = AndroidNotificationDetails(
      'message_channel',
      'Messages',
      channelDescription: 'This channel is for message notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const fallbackPlatformDetails =
        NotificationDetails(android: fallbackDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      fallbackPlatformDetails,
      payload: payload,
    );
    print('Fallback notification shown: $title - $body');
  }
}
