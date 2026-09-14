// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/boorus/booru/types.dart';
import 'package:boorusama/core/boorus/defaults/src/booru_repository_default.dart';
import 'package:boorusama/core/boorus/defaults/widgets.dart';
import 'package:boorusama/core/boorus/engine/types.dart';
import 'package:boorusama/core/bootstrap/boorusama_runtime.dart';
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/debug/types.dart';
import 'package:boorusama/core/developer_options/types.dart';
import 'package:boorusama/core/downloads/filename/types.dart';
import 'package:boorusama/core/posts/post/types.dart';
import 'package:boorusama/core/posts/post/providers.dart';
import 'package:boorusama/core/posts/rating/types.dart';
import 'package:boorusama/core/posts/sources/types.dart';
import 'package:boorusama/core/search/queries/tag_query_composer.dart';
import 'package:boorusama/core/search/selected_tags/types.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/core/tags/autocompletes/autocomplete_repository.dart';

import '../../support/boorusama_test_runtime.dart';

final class FakeBooruPostRequest {
  const FakeBooruPostRequest({
    required this.tags,
    required this.page,
    required this.resultIds,
  });

  final List<String> tags;
  final int page;
  final List<int> resultIds;
}

final class FakeBooruDetailsRequest {
  const FakeBooruDetailsRequest(this.id);

  final int id;
}

final class FakeBooruBackend {
  FakeBooruBackend()
    : config = BooruConfig.defaultConfig(
        booruType: BooruType.danbooru,
        url: 'https://headless.booru.test/',
        customDownloadFileNameFormat: null,
      ).copyWith(name: 'Headless Booru'),
      posts = [
        TestPost(
          id: 101,
          tags: const {'cat', 'blue_hair'},
        ),
        TestPost(
          id: 102,
          tags: const {'landscape'},
        ),
      ] {
    registry.register(
      BooruType.danbooru,
      BooruComponents(
        parser: DefaultBooruParser(config: BooruYamlConfigs.danbooru),
        createBuilder: BaseBooruBuilder.new,
        createRepository: (ref) => _FakeBooruRepository(
          ref: ref,
          backend: this,
        ),
      ),
    );
  }

  final BooruConfig config;
  final List<TestPost> posts;
  final requests = <Object>[];
  final registry = BooruRegistry();

  BooruDb get booruDb => BooruDb(
    boorus: {
      BooruType.danbooru: const BooruScaffold(
        config: BooruYamlConfigs.danbooru,
      ),
    },
  );

  BoorusamaRuntime createRuntime({Settings? settings}) {
    final effectiveSettings =
        settings ??
        Settings.defaultSettings.copyWith(
          currentBooruConfigId: config.id,
        );

    return createTestBoorusamaRuntime(
      initialState: BoorusamaInitialState(
        initialConfig: config,
        configs: [config],
        settings: effectiveSettings,
        developerOptions: DeveloperOptions.defaults,
        logOptions: LogOptions.defaults,
      ),
      booruDb: booruDb,
      booruRegistry: registry,
    );
  }

  PostResult<Post> fetchPosts({
    required List<String> tags,
    required int page,
  }) {
    final matchingPosts = page == 1 ? _filterPosts(tags) : <TestPost>[];
    final request = FakeBooruPostRequest(
      tags: List.unmodifiable(tags),
      page: page,
      resultIds: matchingPosts.map((post) => post.id).toList(growable: false),
    );
    requests.add(request);

    return PostResult(
      posts: List<Post>.unmodifiable(matchingPosts),
      total: page == 1 ? matchingPosts.length : posts.length,
      maxPage: 1,
    );
  }

  Post? fetchPost(PostId postId) {
    final id = switch (postId) {
      NumericPostId(:final value) => value,
      StringPostId(:final value) => int.tryParse(value),
    };
    if (id == null) return null;

    requests.add(FakeBooruDetailsRequest(id));
    for (final post in posts) {
      if (post.id == id) return post;
    }
    return null;
  }

  List<TestPost> _filterPosts(List<String> tags) {
    final positiveTags = <String>[];
    final negativeTags = <String>[];

    for (final tag in tags) {
      final normalized = _normalizeTag(tag);
      if (normalized.isEmpty) continue;

      if (normalized.startsWith('-')) {
        negativeTags.add(normalized.substring(1));
      } else {
        positiveTags.add(normalized);
      }
    }

    return posts
        .where((post) {
          final postTags = post.tags.map(_normalizeTag).toSet();
          return positiveTags.every(postTags.contains) &&
              negativeTags.every((tag) => !postTags.contains(tag));
        })
        .toList(growable: false);
  }

  String _normalizeTag(String tag) => tag.trim().toLowerCase();
}

final class _FakeBooruRepository extends BooruRepositoryDefault {
  _FakeBooruRepository({
    required this.ref,
    required this.backend,
  });

  @override
  final Ref<Object?> ref;

  final FakeBooruBackend backend;

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) =>
      EmptyAutocompleteRepository();

  @override
  PostRepository<Post> post(BooruConfigSearch config) => _FakePostRepository(
    backend: backend,
    config: config,
  );

  @override
  PostLinkGenerator<Post> postLinkGenerator(BooruConfigAuth config) =>
      PluralPostLinkGenerator(baseUrl: config.url);

  @override
  DownloadFilenameGenerator<Post> downloadFilenameBuilder(
    BooruConfigAuth config,
  ) => fallbackFileNameBuilder;

  @override
  Dio dio(BooruConfigAuth config) => Dio(
    BaseOptions(baseUrl: config.url),
  );

  @override
  BooruSiteValidator siteValidator(BooruConfigAuth config) =>
      () async => true;
}

final class _FakePostRepository implements PostRepository<Post> {
  _FakePostRepository({
    required this.backend,
    required this.config,
  });

  final FakeBooruBackend backend;
  final BooruConfigSearch config;

  @override
  PostsOrError<Post> getPosts(
    String tags,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) => TaskEither.right(
    backend.fetchPosts(
      tags: tags.isEmpty ? const [] : tags.split(' '),
      page: page,
    ),
  );

  @override
  PostsOrError<Post> getPostsFromController(
    SearchTagSet controller,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) => TaskEither.right(
    backend.fetchPosts(
      tags: controller.rawTags,
      page: page,
    ),
  );

  @override
  PostOrError<Post> getPost(
    PostId id, {
    PostFetchOptions? options,
  }) => TaskEither.right(backend.fetchPost(id));

  @override
  TagQueryComposer get tagComposer => DefaultTagQueryComposer(config: config);
}

final class TestPost extends SimplePost {
  TestPost({
    required super.id,
    required super.tags,
  }) : super(
         thumbnailImageUrl: '',
         sampleImageUrl: '',
         originalImageUrl: '',
         rating: Rating.general,
         hasComment: false,
         isTranslated: false,
         hasParentOrChildren: false,
         source: PostSource.none(),
         score: 10,
         duration: kNoduration,
         fileSize: 1024,
         format: '.jpg',
         hasSound: null,
         height: 100,
         md5: '',
         videoThumbnailUrl: '',
         videoUrl: '',
         width: 100,
         uploaderId: null,
         metadata: null,
         createdAt: null,
         parentId: null,
         downvotes: null,
         uploaderName: null,
       );
}
