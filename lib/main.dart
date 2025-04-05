import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_osm/services/notification_service.dart';
import 'package:gis_osm/services/user_service.dart';
import 'app.dart';
import 'bloc/auth/auth_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/match_user_repository.dart';
import 'data/repositories/user_location_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await NotificationService.instance.initialize();

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
          ],
          child: MyApp(),
        ),
      ),
    ),
  );
}
