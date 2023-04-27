// Package imports:
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/moebooru.dart';
import 'package:boorusama/boorus/moebooru/domain/posts/moebooru_post.dart';
import 'package:boorusama/boorus/moebooru/domain/utils.dart';
import 'package:boorusama/boorus/moebooru/infra/posts.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<MoebooruPost> parsePost(
  HttpResponse<dynamic> value,
) =>
    parse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map((e) => postDtoToPost(e)).toList();

class MoebooruPostRepositoryApi implements PostRepository {
  final MoebooruApi _api;
  final BlacklistedTagRepository _blacklistedTagRepository;
  final CurrentBooruConfigRepository _currentBooruConfigRepository;

  MoebooruPostRepositoryApi(
    this._api,
    this._blacklistedTagRepository,
    this._currentBooruConfigRepository,
  );

  @override
  Future<List<Post>> getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  }) async {
    final config = await _currentBooruConfigRepository.get();
    final tag = booruFilterConfigToMoebooruTag(config?.ratingFilter);
    final blacklist = await _blacklistedTagRepository.getBlacklist();
    final blacklistedTags = blacklist.map((tag) => tag.name).toSet();

    return _api
        .getPosts(
          config?.login,
          config?.apiKey,
          page,
          [
            ...tags.split(' '),
            if (tag != null) tag,
          ].join(' '),
          limit ?? 60,
        )
        .then(parsePost)
        .then((posts) => posts
            .where((post) =>
                !blacklistedTags.intersection(post.tags.toSet()).isNotEmpty)
            .toList());
  }
}

MoebooruPost postDtoToPost(PostDto postDto) {
  return MoebooruPost(
    id: postDto.id ?? 0,
    thumbnailImageUrl: postDto.previewUrl ?? '',
    sampleImageUrl: postDto.sampleUrl ?? '',
    sampleLargeImageUrl: postDto.jpegUrl ?? '',
    originalImageUrl: postDto.fileUrl ?? '',
    tags: postDto.tags != null ? postDto.tags!.split(' ') : [],
    source: postDto.source,
    rating: mapStringToRating(postDto.rating ?? ''),
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: postDto.hasChildren ?? false,
    downloadUrl: postDto.fileUrl ?? '',
    width: postDto.width!.toDouble(),
    height: postDto.height!.toDouble(),
    md5: postDto.md5 ?? '',
    fileSize: postDto.fileSize ?? 0,
    format: postDto.fileUrl?.split('.').last ?? '',
  );
}
