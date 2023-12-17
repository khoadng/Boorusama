// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/moebooru/types/types.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';

final moebooruPostRepoProvider =
    Provider.family<PostRepository<MoebooruPost>, BooruConfig>(
  (ref, config) {
    final client = ref.watch(moebooruClientProvider(config));

    getTags(List<String> tags) {
      final tag = booruFilterConfigToMoebooruTag(config.ratingFilter);

      return [
        ...tags,
        if (tag != null) tag,
      ];
    }

    return PostRepositoryBuilder(
      fetch: (tags, page, {limit}) => client
          .getPosts(
            page: page,
            tags: getTags(tags),
            limit: limit,
          )
          .then((value) => value.map(postDtoToPost).toList()),
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

final moebooruPostDetailsChildrenProvider =
    FutureProvider.family.autoDispose<List<Post>?, Post>(
  (ref, post) async {
    if (!post.hasParentOrChildren) return null;
    final config = ref.watchConfig;
    final repo = ref.watch(moebooruPostRepoProvider(config));

    final query =
        post.parentId != null ? 'parent:${post.parentId}' : 'parent:${post.id}';

    final posts = await repo.getPosts([query], 1).run();

    return posts.fold(
      (l) => null,
      (r) => r,
    );
  },
);

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
    uploaderId: postDto.creatorId,
  );
}
