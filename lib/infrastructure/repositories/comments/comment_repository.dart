import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/comments/comment.dart';
import 'package:boorusama/domain/comments/i_comment_repository.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
import 'package:dio/dio.dart';

class CommentRepository implements ICommentRepository {
  final Danbooru _api;
  final IAccountRepository _accountRepository;

  CommentRepository(this._api, this._accountRepository);

  @override
  Future<List<Comment>> getCommentsFromPostId(int postId) async {
    //TODO: should change the limit instead of hardcoded number
    final uri = Uri.https(_api.url, "/comments.json", {
      "search[post_id]": postId.toString(),
      "limit": "1000",
    });

    var comments = List<Comment>();
    try {
      final respond = await _api.dio.get(
        uri.toString(),
      );

      for (var item in respond.data) {
        try {
          comments.add(Comment.fromJson(item));
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }
    } on DioError catch (e) {
      // if (e.response.statusCode == 422) {
      //   throw CannotSearchMoreThanTwoTags(
      //       "You cannot search for more than 2 tags at a time. Upgrade your account to search for more tags at once.");
      // }
    }

    return comments;
  }

  @override
  Future<bool> postComment(int postId, String content) async {
    final account = await _accountRepository.get();
    final uri = Uri.https(_api.url, "/comments.json", {
      "login": account.username,
      "api_key": account.apiKey,
    });

    final data = {
      "comment[post_id]": postId,
      "comment[body]": content,
      "comment[do_not_bump_post]": true,
    };

    var respond = await _api.dio.postUri(
      uri,
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) => status < 500,
      ),
    );

    if (respond.statusCode >= 200 && respond.statusCode < 300) {
      print("Add comment to post $postId success");
      return true;
    } else {
      // throw Exception("Failed to add post $postId to favorites");
      print("Failed to add comment to post $postId");
      return false;
    }
  }

  @override
  Future<bool> updateComment(int commentId, String content) async {
    final account = await _accountRepository.get();
    final uri = Uri.https(_api.url, "/comments/$commentId.json", {
      "login": account.username,
      "api_key": account.apiKey,
    });

    final data = {
      "comment[body]": content,
    };

    var respond = await _api.dio.putUri(
      uri,
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) => status < 500,
      ),
    );

    if (respond.statusCode >= 200 && respond.statusCode < 300) {
      print("Update comment $commentId success");
      return true;
    } else {
      // throw Exception("Failed to add post $postId to favorites");
      print("Failed to update comment $commentId");
      return false;
    }
  }
}
