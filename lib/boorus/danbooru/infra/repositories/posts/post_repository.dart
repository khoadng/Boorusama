// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/application/exception.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<Post> parsePost(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map(postDtoToPost).where(isPostValid).toList();

const String _postParams =
    'id,created_at,uploader_id,score,source,md5,last_comment_bumped_at,rating,image_width,image_height,tag_string,fav_count,file_ext,last_noted_at,parent_id,has_children,approver_id,tag_count_general,tag_count_artist,tag_count_character,tag_count_copyright,file_size,up_score,down_score,is_pending,is_flagged,is_deleted,tag_count,updated_at,is_banned,pixiv_id,last_commented_at,has_active_children,bit_flags,tag_count_meta,has_large,has_visible_children,tag_string_general,tag_string_character,tag_string_copyright,tag_string_artist,tag_string_meta,file_url,large_file_url,preview_file_url,comments[is_deleted],artist_commentary';

class PostRepository implements IPostRepository {
  PostRepository(
    Api api,
    IAccountRepository accountRepository,
  )   : _api = api,
        _accountRepository = accountRepository;

  final IAccountRepository _accountRepository;
  final Api _api;

  static const int _limit = 60;

  @override
  Future<List<Post>> getCuratedPosts(
    DateTime date,
    int page,
    TimeScale scale,
  ) async =>
      _accountRepository
          .get()
          .then(
            (account) => _api.getCuratedPosts(
              account.username,
              account.apiKey,
              '${date.year}-${date.month}-${date.day}',
              scale.toString().split('.').last,
              page,
              _postParams,
              _limit,
            ),
          )
          .then(parsePost)
          .catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioError:
            final response = (obj as DioError).response;
            if (response == null) {
              throw Exception('Failed to get popular posts for $date');
            }
            if (response.statusCode == 500) {
              throw DatabaseTimeOut(
                  'Your search took too long to execute and was cancelled.');
            } else {
              throw Exception('Failed to get popular posts for $date');
            }
          default:
        }
        return <Post>[];
      });

  @override
  Future<List<Post>> getMostViewedPosts(
    DateTime date,
  ) async =>
      _accountRepository
          .get()
          .then(
            (account) => _api.getMostViewedPosts(
              account.username,
              account.apiKey,
              '${date.year}-${date.month}-${date.day}',
              _postParams,
            ),
          )
          .then(parsePost)
          .catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioError:
            final response = (obj as DioError).response;
            if (response == null) {
              throw Exception('Failed to get popular posts for $date');
            }
            if (response.statusCode == 500) {
              throw DatabaseTimeOut(
                  'Your search took too long to execute and was cancelled.');
            } else {
              throw Exception('Failed to get popular posts for $date');
            }
          default:
        }
        return <Post>[];
      });

  @override
  Future<List<Post>> getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale,
  ) async =>
      _accountRepository
          .get()
          .then(
            (account) => _api.getPopularPosts(
              account.username,
              account.apiKey,
              '${date.year}-${date.month}-${date.day}',
              scale.toString().split('.').last,
              page,
              _postParams,
              _limit,
            ),
          )
          .then(parsePost)
          .catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioError:
            final response = (obj as DioError).response;
            if (response == null) {
              throw Exception('Failed to get popular posts for $date');
            }
            if (response.statusCode == 500) {
              throw DatabaseTimeOut(
                  'Your search took too long to execute and was cancelled.');
            } else {
              throw Exception('Failed to get popular posts for $date');
            }
          default:
        }
        return <Post>[];
      });

  @override
  Future<List<Post>> getPosts(
    String tags,
    int page, {
    int limit = 50,
    CancelToken? cancelToken,
    bool skipFavoriteCheck = false,
  }) =>
      _accountRepository
          .get()
          .then(
            (account) => _api.getPosts(
              account.username,
              account.apiKey,
              page,
              tags,
              _postParams,
              limit,
              cancelToken: cancelToken,
            ),
          )
          .then(parsePost)
          .catchError((Object e) {
        if (e is DioError) {
          if (e.type == DioErrorType.cancel) {
            // Cancel token triggered, skip this request
            return <Post>[];
          } else if (e.response == null) {
            throw Exception('Failed to get posts for $tags');
          } else if (e.response!.statusCode == 422) {
            throw CannotSearchMoreThanTwoTags(
                "${e.response!.data['message']} Upgrade your account to search for more tags at once.");
          } else if (e.response!.statusCode == 500) {
            throw DatabaseTimeOut(
                'Your search took too long to execute and was cancelled.');
          } else {
            throw Exception('Failed to get posts for $tags');
          }
        } else {
          throw Exception('Failed to get posts for $tags');
        }
      });

  @override
  Future<List<Post>> getPostsFromIds(List<int> ids) =>
      getPosts('id:${ids.join(',')}', 1);
}

class CannotSearchMoreThanTwoTags implements BooruException {
  CannotSearchMoreThanTwoTags(this.message);

  @override
  final String message;
}

class DatabaseTimeOut implements BooruException {
  DatabaseTimeOut(this.message);

  @override
  final String message;
}
