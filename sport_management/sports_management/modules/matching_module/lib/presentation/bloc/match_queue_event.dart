import 'package:equatable/equatable.dart';

abstract class MatchQueueEvent extends Equatable {
  const MatchQueueEvent();

  @override
  List<Object?> get props => [];
}

class LoadQueueStatusEvent extends MatchQueueEvent {}

class JoinQueueEvent extends MatchQueueEvent {
  final Map<String, dynamic> data;

  const JoinQueueEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class LeaveQueueEvent extends MatchQueueEvent {}
