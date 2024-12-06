// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/moebooru/types/types.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/caching.dart';

final moebooruPostRepoProvider =
    Provider.family<PostRepository<MoebooruPost>, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(moebooruClientProvider(config.auth));

    return PostRepositoryBuilder(
      getComposer: () => ref.read(currentTagQueryComposerProvider),
      fetch: (tags, page, {limit}) => client
          .getPosts(
            page: page,
            tags: tags,
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
              .toList()
              .toResult()),
      getSettings: () async => ref.read(imageListingSettingsProvider),
    );
  },
);

final moebooruPopularRepoProvider =
    Provider.family<MoebooruPopularRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(moebooruClientProvider(config));

    return MoebooruPopularRepositoryApi(
      client,
      config,
    );
  },
);

final moebooruArtistCharacterPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
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
    final config = ref.watchConfigSearch;
    final repo = ref.watch(moebooruPostRepoProvider(config));

    final query =
        post.parentId != null ? 'parent:${post.parentId}' : 'parent:${post.id}';

    final r = await repo.getPostsFromTagsOrEmpty(query);

    return r.posts;
  },
);

final moebooruPostDetailsArtistProvider =
    FutureProvider.family.autoDispose<List<Post>, String>((ref, tag) async {
  final config = ref.watchConfigSearch;
  final repo = ref.watch(moebooruArtistCharacterPostRepoProvider(config));
  final blacklistedTags =
      await ref.watch(blacklistTagsProvider(config.auth).future);

  final r = await repo.getPostsFromTagsOrEmpty(tag);

  return filterTags(
    r.posts.take(30).where((e) => !e.isFlash).toList(),
    blacklistedTags,
  );
});

final moebooruPostDetailsCharacterProvider =
    FutureProvider.family.autoDispose<List<Post>, String>((ref, tag) async {
  final config = ref.watchConfigSearch;
  final repo = ref.watch(moebooruArtistCharacterPostRepoProvider(config));
  final blacklistedTags =
      await ref.watch(blacklistTagsProvider(config.auth).future);

  final r = await repo.getPostsFromTagsOrEmpty(tag);

  return filterTags(
    r.posts.take(30).where((e) => !e.isFlash).toList(),
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
    tags: postDto.tags.splitTagString(),
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
