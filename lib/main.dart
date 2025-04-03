import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_osm/services/user_service.dart';
import 'app.dart';
import 'bloc/auth/auth_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/match_user_repository.dart';
import 'data/repositories/user_location_repository.dart';
import 'firebase_options.dart';
import 'notification/bloc/chat_bloc.dart';
import 'notification/bloc/chat_event.dart';
import 'notification/bloc/notification_bloc.dart';
import 'notification/bloc/notification_event.dart';
import 'notification/notification_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificattionSetup.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(
      NotificattionSetup.firebaseMessagingBackgroundHandler);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(AuthRepository())),
        BlocProvider(
            create: (_) => NotificationBloc()..add(ListenForMessages())),
        BlocProvider(create: (_) => ChatBloc()..add(LoadMessages())),
      ],
      child: MaterialApp(
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (_) => UserLocationRepository()),
            RepositoryProvider(create: (_) => AuthRepository()),
            RepositoryProvider(create: (_) => MatchUsersRepository()),
            RepositoryProvider(create: (_) => UserService()),
          ],
          child: MyApp(),
        ),
      ),
    ),
  );
}
