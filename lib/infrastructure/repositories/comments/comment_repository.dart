import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/comments/comment.dart';
import 'package:boorusama/domain/comments/i_comment_repository.dart';
import 'package:boorusama/infrastructure/apis/i_api.dart';
import 'package:dio/dio.dart';

class CommentRepository implements ICommentRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;

  CommentRepository(this._api, this._accountRepository);

  @override
  Future<List<Comment>> getCommentsFromPostId(int postId) =>
      _api.getComments(postId, 1000).then((value) {
        final data = value.response.data;
        var comments = List<Comment>();

        for (var item in data) {
          try {
            comments.add(Comment.fromJson(item));
          } catch (e) {
            print("Cant parse ${item['id']}");
          }
        }
        return comments;
      }).catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioError:
            throw Exception("Failed to get comments from $postId");
            break;
          default:
        }
        return List<Comment>();
      });

  @override
  Future<bool> postComment(int postId, String content) async {
    final account = await _accountRepository.get();
    return _api
        .postComment(account.username, account.apiKey, postId, content, true)
        .then((value) {
      print("Add comment to post $postId success");
      return true;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
        default:
          print("Failed to add comment to post $postId");
      }
      return false;
    });
  }

  @override
  Future<bool> updateComment(int commentId, String content) async {
    final account = await _accountRepository.get();
    return _api
        .updateComment(account.username, account.apiKey, commentId, content)
        .then((value) {
      print("Update comment $commentId success");
      return true;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
        default:
          print("Failed to update comment $commentId");
      }
      return false;
    });
  }
}
