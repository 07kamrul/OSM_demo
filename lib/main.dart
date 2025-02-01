import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'bloc/auth/auth_bloc.dart';
import 'data/repositories/auth_repository.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(AuthRepository())),
        //BlocProvider(create: (context) => LocationBloc(LocationRepository())),
      ],
      child: MyApp(),
    ),
  );
}
