import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class FollowEvent extends Equatable {
  const FollowEvent();

  @override
  List<Object?> get props => [];
}

class FollowUserEvent extends FollowEvent {
  final String followeeId;
  final BuildContext context;

  const FollowUserEvent({required this.followeeId, required this.context});

  @override
  List<Object?> get props => [followeeId, context];
}

class UnfollowUserEvent extends FollowEvent {
  final String followeeId;
  final BuildContext context;

  const UnfollowUserEvent({required this.followeeId, required this.context});

  @override
  List<Object?> get props => [followeeId, context];
}

class LoadFollowersEvent extends FollowEvent {
  final String userId;

  const LoadFollowersEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadFollowingEvent extends FollowEvent {
  final String userId;

  const LoadFollowingEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}


class ShowFollowersViewEvent extends FollowEvent {
  const ShowFollowersViewEvent();
}

class ShowFollowingViewEvent extends FollowEvent {
  const ShowFollowingViewEvent();
}
