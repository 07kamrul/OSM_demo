import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class NotificationInitial extends NotificationState {}

// State when a new message arrives
class NotificationReceived extends NotificationState {
  final String title;
  final String body;

  NotificationReceived({required this.title, required this.body});

  @override
  List<Object?> get props => [title, body];
}
