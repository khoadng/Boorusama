// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/moebooru/types/types.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/utils.dart';
import 'package:boorusama/foundation/caching/caching.dart';

final moebooruPostRepoProvider =
    Provider.family<PostRepository<MoebooruPost>, BooruConfig>(
  (ref, config) {
    final client = ref.watch(moebooruClientProvider(config));

    return PostRepositoryBuilder(
      fetch: (tags, page, {limit}) => client
          .getPosts(
            page: page,
            tags: getTags(
              config,
              tags,
              granularRatingQueries: (tags) => ref
                  .readCurrentBooruBuilder()
                  ?.granularRatingQueryBuilder
                  ?.call(tags, config),
            ),
            limit: limit,
          )
          .then((value) => value
              .map((e) => postDtoToPost(
                    e,
                    PostMetadata(
                      page: page,
                      search: tags.join(' '),
                    ),
                  ))
              .toList()),
      getSettings: () async => ref.read(settingsProvider),
    );
  },
);

final moebooruPopularRepoProvider =
    Provider.family<MoebooruPopularRepository, BooruConfig>(
  (ref, config) {
    final client = ref.watch(moebooruClientProvider(config));

    return MoebooruPopularRepositoryApi(
      client,
      config,
    );
  },
);

final moebooruArtistCharacterPostRepoProvider =
    Provider.family<PostRepository, BooruConfig>(
  (ref, config) {
    return PostRepositoryCacher(
      repository: ref.watch(moebooruPostRepoProvider(config)),
      cache: LruCacher<String, List<Post>>(capacity: 100),
    );
  },
);

final moebooruPostDetailsChildrenProvider =
    FutureProvider.family.autoDispose<List<Post>?, Post>(
  (ref, post) async {
    if (!post.hasParentOrChildren) return null;
    final config = ref.watchConfig;
    final repo = ref.watch(moebooruPostRepoProvider(config));

    final query =
        post.parentId != null ? 'parent:${post.parentId}' : 'parent:${post.id}';

    final posts = await repo.getPosts(query, 1).run();

    return posts.fold(
      (l) => null,
      (r) => r,
    );
  },
);

final moebooruPostDetailsArtistProvider =
    FutureProvider.family.autoDispose<List<Post>, String>((ref, tag) async {
  final config = ref.watchConfig;
  final repo = ref.watch(moebooruArtistCharacterPostRepoProvider(config));
  final blacklistedTags = await ref.watch(blacklistTagsProvider(config).future);

  final posts = await repo.getPosts(tag, 1).run().then(
        (value) => value.fold(
          (l) => <Post>[],
          (r) => r,
        ),
      );

  return filterTags(
    posts.take(30).where((e) => !e.isFlash).toList(),
    blacklistedTags,
  );
});

final moebooruPostDetailsCharacterProvider =
    FutureProvider.family.autoDispose<List<Post>, String>((ref, tag) async {
  final config = ref.watchConfig;
  final repo = ref.watch(moebooruArtistCharacterPostRepoProvider(config));
  final blacklistedTags = await ref.watch(blacklistTagsProvider(config).future);

  final posts = await repo.getPosts(tag, 1).run().then(
        (value) => value.fold(
          (l) => <Post>[],
          (r) => r,
        ),
      );

  return filterTags(
    posts.take(30).where((e) => !e.isFlash).toList(),
    blacklistedTags,
  );
});

MoebooruPost postDtoToPostNoMetadata(PostDto postDto) {
  return postDtoToPost(postDto, null);
}

MoebooruPost postDtoToPost(PostDto postDto, PostMetadata? metadata) {
  final hasChildren = postDto.hasChildren ?? false;
  final hasParent = postDto.parentId != null;
  final hasParentOrChildren = hasChildren || hasParent;

  return MoebooruPost(
    id: postDto.id ?? 0,
    thumbnailImageUrl: postDto.previewUrl ?? '',
    largeImageUrl: postDto.jpegUrl ?? '',
    sampleImageUrl: postDto.sampleUrl ?? '',
    originalImageUrl: postDto.fileUrl ?? '',
    tags: postDto.tags != null ? postDto.tags!.split(' ').toSet() : {},
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
    uploaderId: postDto.creatorId,
    uploaderName: postDto.author,
    metadata: metadata,
  );
}
