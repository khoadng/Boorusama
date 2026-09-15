// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/bookmarks/types.dart';
import 'package:boorusama/core/boorus/booru/types.dart';
import 'package:boorusama/core/boorus/defaults/src/booru_repository_default.dart';
import 'package:boorusama/core/boorus/defaults/widgets.dart';
import 'package:boorusama/core/boorus/engine/types.dart';
import 'package:boorusama/core/bootstrap/boorusama_runtime.dart';
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/debug/types.dart';
import 'package:boorusama/core/developer_options/types.dart';
import 'package:boorusama/core/downloads/downloader/types.dart';
import 'package:boorusama/core/downloads/filename/types.dart';
import 'package:boorusama/core/downloads/urls/types.dart';
import 'package:boorusama/core/posts/details_parts/types.dart';
import 'package:boorusama/core/posts/details_parts/widgets.dart';
import 'package:boorusama/core/posts/post/providers.dart';
import 'package:boorusama/core/posts/post/types.dart';
import 'package:boorusama/core/posts/rating/types.dart';
import 'package:boorusama/core/posts/sources/types.dart';
import 'package:boorusama/core/search/histories/src/types/search_history_repository.dart';
import 'package:boorusama/core/search/queries/tag_query_composer.dart';
import 'package:boorusama/core/search/selected_tags/types.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/core/tags/autocompletes/autocomplete_repository.dart';
import 'package:boorusama/core/tags/favorites/types.dart';
import 'package:boorusama/foundation/filesystem.dart';
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/pincode/pincode.dart';
import 'package:boorusama/foundation/url_launcher.dart';

import '../../support/boorusama_test_runtime.dart';

final class FakeBooruPostRequest {
  const FakeBooruPostRequest({
    required this.siteUrl,
    required this.tags,
    required this.page,
    required this.resultIds,
  });

  final String siteUrl;
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
          source: RawWebSource(
            faviconUrl: null,
            url: 'https://source.booru.test/101',
            uri: Uri.parse('https://source.booru.test/101'),
          ),
        ),
        TestPost(
          id: 102,
          tags: const {'landscape'},
        ),
      ] {
    configB = BooruConfig.fromJson({
      ...config.toJson(),
      'id': 2,
      'url': 'https://headless-b.booru.test/',
      'name': 'Headless Booru B',
    });
    postsB = [
      TestPost(
        id: 201,
        tags: const {'dog', 'green_eyes'},
      ),
      TestPost(
        id: 202,
        tags: const {'cityscape'},
      ),
    ];
    registry.register(
      BooruType.danbooru,
      BooruComponents(
        parser: DefaultBooruParser(config: BooruYamlConfigs.danbooru),
        createBuilder: _FakeBooruBuilder.new,
        createRepository: (ref) => _FakeBooruRepository(
          ref: ref,
          backend: this,
        ),
      ),
    );
  }

  final BooruConfig config;
  final List<TestPost> posts;
  late final BooruConfig configB;
  late final List<TestPost> postsB;
  final requests = <Object>[];
  final registry = BooruRegistry();

  BooruDb get booruDb => BooruDb(
    boorus: {
      BooruType.danbooru: const BooruScaffold(
        config: BooruYamlConfigs.danbooru,
      ),
    },
  );

  BoorusamaRuntime createRuntime({
    Settings? settings,
    List<BooruConfig>? configs,
    BooruConfig? initialConfig,
    BookmarkRepository? bookmarkRepository,
    DownloadService? downloadService,
    FavoriteTagRepository? favoriteTagRepository,
    PinCredentialRepositoryFactory? pinCredentialRepositoryFactory,
    SearchHistoryRepository? searchHistoryRepository,
    AppFilePicker? appFilePicker,
    AppFileSystem? fileSystem,
    ExternalUrlLauncher? externalUrlLauncher,
  }) {
    final effectiveConfigs = configs ?? [config];
    final effectiveInitialConfig = initialConfig ?? effectiveConfigs.first;
    final effectiveSettings =
        settings?.copyWith(
          currentBooruConfigId: effectiveInitialConfig.id,
        ) ??
        Settings.defaultSettings.copyWith(
          currentBooruConfigId: effectiveInitialConfig.id,
        );

    return createTestBoorusamaRuntime(
      initialState: BoorusamaInitialState(
        initialConfig: effectiveInitialConfig,
        configs: effectiveConfigs,
        settings: effectiveSettings,
        developerOptions: DeveloperOptions.defaults,
        logOptions: LogOptions.defaults,
      ),
      booruDb: booruDb,
      booruRegistry: registry,
      bookmarkRepository: bookmarkRepository,
      downloadService: downloadService,
      favoriteTagRepository: favoriteTagRepository,
      searchHistoryRepository: searchHistoryRepository,
      appFilePicker: appFilePicker,
      fileSystem: fileSystem,
      externalUrlLauncher: externalUrlLauncher,
      pinCredentialRepositoryFactory: pinCredentialRepositoryFactory,
    );
  }

  PostResult<Post> fetchPosts({
    required String siteUrl,
    required List<String> tags,
    required int page,
  }) {
    final matchingPosts = page == 1
        ? _filterPosts(tags, siteUrl: siteUrl)
        : <TestPost>[];
    final request = FakeBooruPostRequest(
      siteUrl: siteUrl,
      tags: List.unmodifiable(tags),
      page: page,
      resultIds: matchingPosts.map((post) => post.id).toList(growable: false),
    );
    requests.add(request);

    return PostResult(
      posts: List<Post>.unmodifiable(matchingPosts),
      total: page == 1 ? matchingPosts.length : _postsFor(siteUrl).length,
      maxPage: 1,
    );
  }

  Post? fetchPost(PostId postId, {required String siteUrl}) {
    final id = switch (postId) {
      NumericPostId(:final value) => value,
      StringPostId(:final value) => int.tryParse(value),
    };
    if (id == null) return null;

    requests.add(FakeBooruDetailsRequest(id));
    for (final post in _postsFor(siteUrl)) {
      if (post.id == id) return post;
    }
    return null;
  }

  List<TestPost> _filterPosts(
    List<String> tags, {
    required String siteUrl,
  }) {
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

    return _postsFor(siteUrl)
        .where((post) {
          final postTags = post.tags.map(_normalizeTag).toSet();
          return positiveTags.every(postTags.contains) &&
              negativeTags.every((tag) => !postTags.contains(tag));
        })
        .toList(growable: false);
  }

  List<TestPost> _postsFor(String siteUrl) =>
      siteUrl == configB.url ? postsB : posts;

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
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config) =>
      _FakeDownloadFileUrlExtractor(config.url);

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

final class _FakeDownloadFileUrlExtractor implements DownloadFileUrlExtractor {
  const _FakeDownloadFileUrlExtractor(this.baseUrl);

  final String baseUrl;

  String get normalizedBaseUrl => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  @override
  Future<DownloadUrlData> getDownloadFileUrl({
    required Post post,
    required String quality,
  }) async =>
      DownloadUrlData.urlOnly('$normalizedBaseUrl/posts/${post.id}.jpg');
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
      siteUrl: config.auth.url,
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
      siteUrl: config.auth.url,
      tags: controller.rawTags,
      page: page,
    ),
  );

  @override
  PostOrError<Post> getPost(
    PostId id, {
    PostFetchOptions? options,
  }) => TaskEither.right(
    backend.fetchPost(id, siteUrl: config.auth.url),
  );

  @override
  TagQueryComposer get tagComposer => DefaultTagQueryComposer(config: config);
}

final class TestPost extends SimplePost {
  TestPost({
    required super.id,
    required super.tags,
    PostSource? source,
  }) : super(
         thumbnailImageUrl: '',
         sampleImageUrl: '',
         originalImageUrl: '',
         rating: Rating.general,
         hasComment: false,
         isTranslated: false,
         hasParentOrChildren: false,
         source: source ?? PostSource.none(),
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

final class _FakeBooruBuilder extends BaseBooruBuilder {
  @override
  PostDetailsUIBuilder get postDetailsUIBuilder => PostDetailsUIBuilder(
    preview: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar(),
    },
    full: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar(),
      DetailsPart.source: (context) => const DefaultInheritedSourceSection(),
    },
  );
}
