import 'package:equatable/equatable.dart';
import 'package:softconnect/features/message/domain/use_case/inbox_usecase.dart';

abstract class InboxEvent extends Equatable {
  const InboxEvent();

  @override
  List<Object?> get props => [];
}

class LoadInboxEvent extends InboxEvent {
  final GetInboxParams params;

  const LoadInboxEvent(this.params);

  @override
  List<Object?> get props => [params];
}
