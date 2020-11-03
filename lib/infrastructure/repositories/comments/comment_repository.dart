import 'package:boorusama/domain/comments/comment.dart';
import 'package:boorusama/domain/comments/i_comment_repository.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class CommentRepository implements ICommentRepository {
  final Danbooru _api;

  CommentRepository(this._api);

  @override
  Future<List<Comment>> getCommentsFromPostId(int postId) async {
    //TODO: should change the limit instead of hardcoded number
    final uri = Uri.https(_api.url, "/comments.json", {
      "search[post_id]": postId.toString(),
      "limit": "1000",
    });

    var comments = List<Comment>();
    try {
      final respond = await _api.dio.get(uri.toString(),
          options: buildCacheOptions(Duration(minutes: 1)));

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
}
