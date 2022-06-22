// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/i_comment_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/api.dart';
import 'package:boorusama/core/infrastructure/http_parser.dart';

List<Comment> parseComment(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => Comment.fromJson(item),
    );

class CommentRepository implements ICommentRepository {
  CommentRepository(
    this._api,
    this._accountRepository,
  );

  final Api _api;
  final IAccountRepository _accountRepository;

  @override
  Future<List<Comment>> getCommentsFromPostId(
    int postId, {
    CancelToken? cancelToken,
  }) async {
    try {
      return _api
          .getComments(
            postId,
            1000,
            cancelToken: cancelToken,
          )
          .then(parseComment);
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        throw Exception('Failed to get comments for $postId');
      }
    }
  }

  @override
  Future<bool> postComment(int postId, String content) => _accountRepository
          .get()
          .then((account) => _api.postComment(
              account.username, account.apiKey, postId, content, true))
          .then((value) {
        return true;
      }).catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioError:
          default:
        }
        return false;
      });

  @override
  Future<bool> updateComment(int commentId, String content) =>
      _accountRepository
          .get()
          .then((account) => _api.updateComment(
              account.username, account.apiKey, commentId, content))
          .then((value) {
        return true;
      }).catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioError:
          default:
        }
        return false;
      });
}
