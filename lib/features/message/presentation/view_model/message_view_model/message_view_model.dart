import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/message/domain/use_case/message_usecase.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_event.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_state.dart';

class MessageViewModel extends Bloc<MessageEvent, MessageState> {
  final GetMessagesBetweenUsersUseCase getMessagesBetweenUsersUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;

  MessageViewModel({
    required this.getMessagesBetweenUsersUseCase,
    required this.sendMessageUseCase,
    required this.deleteMessageUseCase,
  }) : super(MessageInitialState()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
  }

  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<MessageState> emit) async {
    emit(MessageLoadingState());
    try {
      final result = await getMessagesBetweenUsersUseCase(
        GetMessagesParams(event.senderId, event.receiverId),
      );
      result.fold(
        (failure) => emit(MessageErrorState(failure.message)),
        (messages) => emit(MessageLoadedMessagesState(messages)),
      );
    } catch (e) {
      emit(MessageErrorState(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<MessageState> emit) async {
    try {
      final result = await sendMessageUseCase(
        SendMessageParams(event.recipientId, event.content, event.senderId),
      );
      result.fold(
        (failure) => emit(MessageErrorState(failure.message)),
        (_) => emit(MessageSentState()),
      );
    } catch (e) {
      emit(MessageErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteMessage(DeleteMessageEvent event, Emitter<MessageState> emit) async {
    try {
      final result = await deleteMessageUseCase(DeleteMessageParams(event.messageId));
      result.fold(
        (failure) => emit(MessageErrorState(failure.message)),
        (_) => emit(MessageDeletedState()),
      );
    } catch (e) {
      emit(MessageErrorState(e.toString()));
    }
  }
}
