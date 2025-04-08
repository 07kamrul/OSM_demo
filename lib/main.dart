import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gis_osm/services/message_notification.dart';
import 'package:gis_osm/services/message_service.dart';
import 'package:gis_osm/services/user_service.dart';
import 'bloc/auth/auth_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/match_user_repository.dart';
import 'data/repositories/user_location_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screen/auth_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

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
              FirebaseNotificationService.initialize(context);
              return MaterialApp(
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
                debugShowCheckedModeBanner: false,
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
