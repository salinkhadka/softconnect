import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/message/domain/entity/message_inbox_entity.dart';
import 'package:softconnect/features/message/domain/use_case/inbox_usecase.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_event.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_state.dart';
import 'package:dartz/dartz.dart';

class InboxViewModel extends Bloc<InboxEvent, InboxState> {
  final GetInboxUseCase getInboxUseCase;

  InboxViewModel(this.getInboxUseCase) : super(MessageInitialState()) {
    on<LoadInboxEvent>(_onLoadInbox);
  }

  Future<void> _onLoadInbox(
    LoadInboxEvent event,
    Emitter<InboxState> emit,
  ) async {
    emit(MessageLoadingState());
    try {
      final Either<Failure, List<MessageInboxEntity>> result =
          await getInboxUseCase(event.params);

      result.fold(
        (failure) => emit(MessageErrorState(failure.message)),
        (inboxList) => emit(MessageLoadedState(inboxList)),
      );
    } catch (e) {
      emit(MessageErrorState(e.toString()));
    }
  }
}
