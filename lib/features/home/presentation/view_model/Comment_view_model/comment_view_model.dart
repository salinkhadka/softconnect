import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:softconnect/features/home/domain/use_case/createCommentUseCase.dart';
import 'package:softconnect/features/home/domain/use_case/getCommentsUseCase.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentViewModel extends Bloc<CommentEvent, CommentState> {
  final CreateCommentUsecase createCommentUsecase;
  final GetCommentsByPostIdUsecase getCommentsUsecase;

  CommentViewModel({
    required this.createCommentUsecase,
    required this.getCommentsUsecase,
  }) : super(CommentState.initial()) {
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
  }

  Future<void> _onLoadComments(LoadComments event, Emitter<CommentState> emit) async {
  print("Loading comments for postId: ${event.postId}");
  emit(state.copyWith(isLoading: true));
  final result = await getCommentsUsecase(GetCommentsByPostIdParams(event.postId));
  result.fold(
    (failure) {
      print("Load comments failed: ${failure.message}");
      emit(state.copyWith(isLoading: false, error: failure.message));
    },
    (comments) {
      print("Load comments succeeded, count: ${comments.length}");
      emit(state.copyWith(isLoading: false, comments: comments));
    },
  );
}


  Future<void> _onAddComment(AddComment event, Emitter<CommentState> emit) async {
  print("Adding comment for postId: ${event.postId}");
  final result = await createCommentUsecase(CreateCommentParams(
    userId: event.userId,
    postId: event.postId,
    content: event.content,
    parentCommentId: event.parentCommentId,
  ));
  result.fold(
    (failure) {
      print("Add comment failed: ${failure.message}");
      emit(state.copyWith(error: failure.message));
    },
    (_) {
      print("Add comment succeeded, loading comments");
      add(LoadComments(event.postId)); // This triggers loading updated comments
    },
  );
}

}
