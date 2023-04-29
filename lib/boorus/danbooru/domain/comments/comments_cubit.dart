// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments.dart';

class CommentsState extends Equatable {
  const CommentsState({
    required this.commentsMap,
  });

  final Map<int, List<Comment>> commentsMap;

  @override
  List<Object?> get props => [commentsMap];
}

class CommentsCubit extends Cubit<CommentsState> {
  final CommentRepository repository;

  CommentsCubit({required this.repository})
      : super(const CommentsState(commentsMap: {}));

  Future<void> getCommentsFromPostId(int postId) async {
    final comments = state.commentsMap[postId];
    if (comments == null) {
      final newComments =
          await repository.getCommentsFromPostId(postId, cancelToken: null);
      final newMap = Map<int, List<Comment>>.from(state.commentsMap)
        ..[postId] = newComments;
      emit(CommentsState(commentsMap: newMap));
    }
  }
}
