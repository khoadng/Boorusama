// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/utils.dart';
import 'package:boorusama/clients/moebooru/moebooru_client.dart';
import 'package:boorusama/clients/moebooru/types/types.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';

class MoebooruPostRepositoryApi
    with SettingsRepositoryMixin
    implements PostRepository {
  MoebooruPostRepositoryApi(
    this.client,
    this.booruConfig,
    this.settingsRepository,
  );

  final MoebooruClient client;
  final BooruConfig booruConfig;
  @override
  final SettingsRepository settingsRepository;

  List<String> getTags(BooruConfig config, String tags) {
    final tag = booruFilterConfigToMoebooruTag(config.ratingFilter);

    return [
      ...tags.split(' '),
      if (tag != null) tag,
    ];
  }

  @override
  PostsOrError getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  }) =>
      TaskEither.Do(($) async {
        final response = await $(tryFetchRemoteData(
          fetcher: () => getPostsPerPage().then((lim) => client.getPosts(
                page: page,
                tags: getTags(booruConfig, tags),
                limit: limit ?? lim,
              )),
        ));

        final data = response.map(postDtoToPost).toList();

        return data;
      });
}

MoebooruPost postDtoToPost(PostDto postDto) {
  final hasChildren = postDto.hasChildren ?? false;
  final hasParent = postDto.parentId != null;
  final hasParentOrChildren = hasChildren || hasParent;

  return MoebooruPost(
    id: postDto.id ?? 0,
    thumbnailImageUrl: postDto.previewUrl ?? '',
    sampleImageUrl: postDto.sampleUrl ?? '',
    originalImageUrl: postDto.fileUrl ?? '',
    tags: postDto.tags != null ? postDto.tags!.split(' ') : [],
    source: PostSource.from(postDto.source),
    rating: mapStringToRating(postDto.rating ?? ''),
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: hasParentOrChildren,
    width: postDto.width?.toDouble() ?? 1,
    height: postDto.height?.toDouble() ?? 1,
    md5: postDto.md5 ?? '',
    fileSize: postDto.fileSize ?? 0,
    format: postDto.fileUrl?.split('.').lastOrNull ?? '',
    score: postDto.score ?? 0,
    createdAt: postDto.createdAt != null
        ? DateTime.fromMillisecondsSinceEpoch(postDto.createdAt! * 1000)
        : null,
    parentId: postDto.parentId,
  );
}
