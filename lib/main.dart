import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_osm/services/background_notification.dart';
import 'package:gis_osm/services/foreground_notification.dart';
import 'package:gis_osm/services/message_service.dart';
import 'package:gis_osm/services/user_service.dart';
import 'bloc/auth/auth_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/match_user_repository.dart';
import 'data/repositories/user_location_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screen/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  DartPluginRegistrant.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // Request notification permission
  await FirebaseMessaging.instance.requestPermission();

  // Get FCM token (for testing)
  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(AuthRepository())),
      ],
      child: MaterialApp(
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (_) => UserLocationRepository()),
            RepositoryProvider(create: (_) => AuthRepository()),
            RepositoryProvider(create: (_) => MatchUsersRepository()),
            RepositoryProvider(create: (_) => UserService()),
            RepositoryProvider(create: (_) => MessageService()),
          ],
          child: Builder(
            builder: (context) {
              // Initialize notifications here
              initializeService(context);
              ForegroundMessageNotificationService.initialize(context);
              WidgetsBinding.instance.addPostFrameCallback((_) async {});
              return MaterialApp(
                debugShowCheckedModeBanner: false,

                locale: Locale('en', 'US'), // Optional: Set default locale
                supportedLocales: [
                  Locale('en', 'US'), // Add other locales as needed
                ],
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                title: 'Flutter Auth with BLoC',
                theme: ThemeData(primarySwatch: Colors.blue),
                home: AuthScreen(),
              );
            },
          ),
        ),
      ),
    ),
  );
}
