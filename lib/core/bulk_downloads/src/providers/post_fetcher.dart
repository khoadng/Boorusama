// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../blacklists/providers.dart';
import '../../../configs/config/types.dart';
import '../../../posts/filter/types.dart';
import '../../../posts/post/providers.dart';
import '../../../posts/post/types.dart';
import '../../../search/selected_tags/types.dart';
import '../types/download_configs.dart';
import '../types/download_task.dart';

class PostFetcherState extends Equatable {
  const PostFetcherState({
    required this.blacklistedPatterns,
    required this.postRepo,
  });

  final List<List<TagExpression>> blacklistedPatterns;
  final PostRepository postRepo;

  @override
  List<Object> get props => [blacklistedPatterns, postRepo];
}

typedef PostFetcherParams = ({
  BooruConfigFilter filter,
  BooruConfigSearch config,
  DownloadConfigs? downloadConfigs,
});

class PostResult extends Equatable {
  const PostResult({
    required this.posts,
    required this.isFiltered,
  });

  const PostResult.empty() : this(posts: const [], isFiltered: false);

  factory PostResult.noFilter(List<Post> posts) =>
      PostResult(posts: posts, isFiltered: false);

  final List<Post> posts;
  final bool isFiltered;

  bool get isEmpty => !isFiltered && posts.isEmpty;

  @override
  List<Object> get props => [posts, isFiltered];
}

class PostFetcher
    extends FamilyAsyncNotifier<PostFetcherState, PostFetcherParams> {
  @override
  Future<PostFetcherState> build(
    PostFetcherParams arg,
  ) async {
    final (:filter, :config, :downloadConfigs) = arg;
    final postRepo = ref.watch(postRepoProvider(config));

    final fallbackBlacklistedTags = await ref.read(
      blacklistTagsProvider(filter).future,
    );
    final blacklistedTags =
        downloadConfigs?.blacklistedTags ?? fallbackBlacklistedTags;

    return PostFetcherState(
      blacklistedPatterns: _parsePatterns(blacklistedTags),
      postRepo: postRepo,
    );
  }

  Future<PostResult> getPosts({
    required SearchTagSet tags,
    required int page,
    required DownloadTask task,
  }) async {
    final currentState = await future;

    final result = await currentState.postRepo
        .getPostsFromController(
          //TODO: assume space delimited tags for now, if we need to support tag with space, we need to change this
          tags,
          page,
          limit: task.perPage,
          options: PostFetchOptions.raw,
        )
        .run();

    return result.fold(
      (_) => const PostResult.empty(),
      (r) {
        final posts = r.posts;
        if (posts.isEmpty) return const PostResult.empty();

        final taskPatterns = _parsePatterns(queryAsList(task.blacklistedTags));
        final effectivePatterns = [
          ...taskPatterns,
          ...currentState.blacklistedPatterns,
        ];

        return _filter(
          posts,
          effectivePatterns,
        );
      },
    );
  }
}

List<List<TagExpression>> _parsePatterns(Iterable<String>? patterns) {
  if (patterns == null || patterns.isEmpty) return [];

  return patterns
      .map((tag) => tag.split(' ').map(TagExpression.parse).toList())
      .toList();
}

PostResult _filter(
  List<Post> posts,
  Iterable<List<TagExpression>>? patterns,
) {
  if (patterns == null || patterns.isEmpty) return PostResult.noFilter(posts);

  final filterIds = <int>{};

  for (final post in posts) {
    for (final pattern in patterns) {
      if (post.containsTagPattern(pattern)) {
        filterIds.add(post.id);
        break;
      }
    }
  }

  final filteredPosts = posts.where((e) => !filterIds.contains(e.id)).toList();

  return PostResult(
    posts: filteredPosts,
    isFiltered: filterIds.isNotEmpty,
  );
}
