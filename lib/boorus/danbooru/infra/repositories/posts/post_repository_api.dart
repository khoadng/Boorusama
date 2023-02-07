// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/handle_error.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/core/domain/posts/rating.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<Post> parsePost(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map(postDtoToPost).where(isPostValid).toList();

List<Post> Function(HttpResponse<dynamic> value) parsePostWithOptions({
  required bool includeInvalid,
}) =>
    (value) => includeInvalid
        ? parse(
            value: value,
            converter: (item) => PostDto.fromJson(item),
          ).map(postDtoToPost).toList()
        : parsePost(value);

const String postParams =
    'id,created_at,uploader_id,score,source,md5,last_comment_bumped_at,rating,image_width,image_height,tag_string,fav_count,file_ext,last_noted_at,parent_id,has_children,approver_id,tag_count_general,tag_count_artist,tag_count_character,tag_count_copyright,file_size,up_score,down_score,is_pending,is_flagged,is_deleted,tag_count,updated_at,is_banned,pixiv_id,last_commented_at,has_active_children,bit_flags,tag_count_meta,has_large,has_visible_children,tag_string_general,tag_string_character,tag_string_copyright,tag_string_artist,tag_string_meta,file_url,large_file_url,preview_file_url,comments[is_deleted],artist_commentary';

class PostRepositoryApi implements PostRepository {
  PostRepositoryApi(
    Api api,
    AccountRepository accountRepository,
  )   : _api = api,
        _accountRepository = accountRepository;

  final AccountRepository _accountRepository;
  final Api _api;

  static const int _limit = 60;

  @override
  Future<List<Post>> getPosts(
    String tags,
    int page, {
    int? limit,
    bool? includeInvalid,
  }) {
    return _accountRepository
        .get()
        .then(
          (account) => _api.getPosts(
            account.username,
            account.apiKey,
            page,
            tags,
            postParams,
            limit ?? _limit,
          ),
        )
        .then(parsePostWithOptions(includeInvalid: includeInvalid ?? false))
        .catchError((e) {
      handleError(e);

      return <Post>[];
    });
  }

  @override
  Future<List<Post>> getPostsFromIds(List<int> ids) => getPosts(
        'id:${ids.join(',')}',
        1,
        limit: ids.length,
      );

  @override
  Future<bool> putTag(int postId, String tagString) => _accountRepository
      .get()
      .then((account) => _api.putTag(account.username, account.apiKey, postId, {
            'post[tag_string]': tagString,
            'post[old_tag_string]': '',
          }))
      .then((value) => value.response.statusCode == 200);
}

List<String> splitTag(String tags) => tags.isEmpty ? [] : tags.split(' ');

Post postDtoToPost(PostDto dto) {
  try {
    final comments = dto.comments
        .map((e) => CommentDto.fromJson(e))
        .map((e) => commentDtoToComment(e))
        .where((c) => !c.isDeleted)
        .toList();

    final artistCommentaryDto = dto.artistCommentary != null
        ? ArtistCommentaryDto.fromJson(dto.artistCommentary)
        : null;

    return Post(
      id: dto.id!,
      previewImageUrl: dto.previewFileUrl ?? '',
      normalImageUrl: dto.largeFileUrl ?? '',
      fullImageUrl: dto.fileUrl ?? '',
      copyrightTags: splitTag(dto.copyrightTags),
      characterTags: splitTag(dto.characterTags),
      artistTags: splitTag(dto.artistTags),
      generalTags: splitTag(dto.generalTags),
      metaTags: splitTag(dto.tagsMeta),
      tags: splitTag(dto.tags),
      width: dto.imageWidth.toDouble(),
      height: dto.imageHeight.toDouble(),
      format: dto.fileExt,
      md5: dto.md5 ?? '',
      lastCommentAt: dto.lastCommentedAt,
      source: dto.source,
      createdAt: dto.createdAt,
      score: dto.score,
      upScore: dto.upScore,
      downScore: dto.downScore,
      favCount: dto.favCount,
      uploaderId: dto.uploaderId,
      rating: mapStringToRating(dto.rating),
      fileSize: dto.fileSize,
      pixivId: dto.pixivId,
      isBanned: dto.isBanned,
      hasChildren: dto.hasChildren,
      parentId: dto.parentId,
      hasLarge: dto.hasLarge ?? false,
      comments: comments.take(3).toList(),
      totalComments: comments.length,
      artistCommentary: artistCommentaryDto != null
          ? artistCommentaryDtoToArtistCommentary(artistCommentaryDto)
          : null,
    );
  } catch (e) {
    return Post.empty();
  }
}
