import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/i_comment_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/i_user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentCubit extends Cubit<AsyncLoadState<List<Comment>>> {
  CommentCubit({
    required this.commentRepository,
    required this.userRepository,
  }) : super(AsyncLoadState.initial()) {
    print("comment cubit created");
  }

  final ICommentRepository commentRepository;
  final IUserRepository userRepository;

  void getComment(int postId) {
    TryAsync<List<Comment>>(
        action: () => commentRepository.getCommentsFromPostId(postId),
        onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
        onLoading: () => emit(AsyncLoadState.loading()),
        onSuccess: (comments) async {
          final dtos = await commentRepository.getCommentsFromPostId(postId);
          final comments =
              dtos.where((e) => e.creatorId != null).toList().toList();

          final userList = comments.map((e) => e.creatorId).toSet().toList();
          final users =
              await userRepository.getUsersByIdStringComma(userList.join(","));

          final commentsWithAuthor =
              (comments..sort((a, b) => a.id.compareTo(b.id))).map((comment) {
            final author =
                users.where((user) => user.id == comment.creatorId).first;
            return comment.copyWith(author: author);
          }).toList();

          emit(AsyncLoadState.success(commentsWithAuthor));
        });
  }
}
