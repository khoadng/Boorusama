// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/utils.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/handle_error.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts/post.dart' as core;
import 'package:boorusama/core/domain/posts/post_image_source_composer.dart';
import 'package:boorusama/core/domain/posts/rating.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<DanbooruPost> parsePost(
  HttpResponse<dynamic> value,
  ImageSourceComposer<PostDto> urlComposer,
) =>
    parse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map((e) => postDtoToPost(e, urlComposer)).where(isPostValid).toList();

List<DanbooruPost> Function(
  HttpResponse<dynamic> value,
) parsePostWithOptions({
  required bool includeInvalid,
  required ImageSourceComposer<PostDto> urlComposer,
}) =>
    (value) => includeInvalid
        ? parse(
            value: value,
            converter: (item) => PostDto.fromJson(item),
          ).map((e) => postDtoToPost(e, urlComposer)).toList()
        : parsePost(value, urlComposer);

class PostRepositoryApi implements DanbooruPostRepository {
  PostRepositoryApi(
    DanbooruApi api,
    CurrentBooruConfigRepository currentBooruConfigRepository,
    this.urlComposer,
  )   : _api = api,
        _currentUserBooruRepository = currentBooruConfigRepository;

  final CurrentBooruConfigRepository _currentUserBooruRepository;
  final DanbooruApi _api;
  final ImageSourceComposer<PostDto> urlComposer;

  static const int _limit = 60;

  @override
  Future<List<DanbooruPost>> getPosts(
    String tags,
    int page, {
    int? limit,
    bool? includeInvalid,
  }) async {
    final booruConfig = await _currentUserBooruRepository.get();
    final tag = booruFilterConfigToDanbooruTag(booruConfig?.ratingFilter);
    final deletedStatusTag = booruConfigDeletedBehaviorToDanbooruTag(
      booruConfig?.deletedItemBehavior,
    );

    return _api
        .getPosts(
          booruConfig?.login,
          booruConfig?.apiKey,
          page,
          [
            ...tags.split(' '),
            if (tag != null) tag,
            if (deletedStatusTag != null) deletedStatusTag,
          ].join(' '),
          limit ?? _limit,
        )
        .then(parsePostWithOptions(
          includeInvalid: includeInvalid ?? false,
          urlComposer: urlComposer,
        ))
        .catchError((e) {
      handleError(e);

      return <DanbooruPost>[];
    });
  }

  @override
  Future<List<DanbooruPost>> getPostsFromIds(List<int> ids) => getPosts(
        'id:${ids.join(',')}',
        1,
        limit: ids.length,
      );

  @override
  Future<bool> putTag(int postId, String tagString) =>
      _currentUserBooruRepository
          .get()
          .then((booruConfig) => _api.putTag(
                booruConfig?.login,
                booruConfig?.apiKey,
                postId,
                {
                  'post[tag_string]': tagString,
                  'post[old_tag_string]': '',
                },
              ))
          .then((value) => value.response.statusCode == 200);

  @override
  Future<List<core.Post>> getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  }) =>
      getPosts(
        tags,
        page,
        limit: limit,
        includeInvalid: true,
      );
}

List<String> splitTag(String tags) => tags.isEmpty ? [] : tags.split(' ');

DanbooruPost postDtoToPost(
  PostDto dto,
  ImageSourceComposer<PostDto> urlComposer,
) {
  try {
    final sources = urlComposer.compose(dto);

    return DanbooruPost(
      id: dto.id!,
      thumbnailImageUrl: sources.thumbnail,
      sampleImageUrl: sources.sample,
      originalImageUrl: sources.original,
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
    );
  } catch (e) {
    return DanbooruPost.empty();
  }
}
