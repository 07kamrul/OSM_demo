import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_osm/services/user_service.dart';
import 'app.dart';
import 'bloc/auth/auth_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/match_user_repository.dart';
import 'data/repositories/user_location_repository.dart';
import 'notification_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificattionSetup.initializeFirebase();
  FirebaseMessaging.onBackgroundMessage(
      NotificattionSetup.firebaseMessagingBackgroundHandler);
  NotificattionSetup.getToken();
  NotificattionSetup.handleTerminatedMessages();
  NotificattionSetup.setupForegroundNotification();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(AuthRepository())),
        //BlocProvider(create: (context) => LocationBloc(LocationRepository())),
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
