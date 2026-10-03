// Dart imports:
import 'dart:async';
import 'dart:collection';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/core/artists/widgets.dart';
import 'package:boorusama/core/bookmarks/types.dart';
import 'package:boorusama/core/boorus/booru/types.dart';
import 'package:boorusama/core/boorus/defaults/src/booru_repository_default.dart';
import 'package:boorusama/core/boorus/defaults/widgets.dart';
import 'package:boorusama/core/boorus/engine/types.dart';
import 'package:boorusama/core/bootstrap/boorusama_runtime.dart';
import 'package:boorusama/core/configs/config/providers.dart';
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/debug/types.dart';
import 'package:boorusama/core/developer_options/types.dart';
import 'package:boorusama/core/downloads/downloader/types.dart';
import 'package:boorusama/core/downloads/filename/types.dart';
import 'package:boorusama/core/downloads/urls/types.dart';
import 'package:boorusama/core/errors/error.dart';
import 'package:boorusama/core/blacklists/types.dart';
import 'package:boorusama/core/posts/details_parts/types.dart';
import 'package:boorusama/core/posts/details_parts/widgets.dart';
import 'package:boorusama/core/posts/favorites/widgets.dart';
import 'package:boorusama/core/posts/post/providers.dart';
import 'package:boorusama/core/posts/post/types.dart';
import 'package:boorusama/core/posts/sources/types.dart';
import 'package:boorusama/core/search/histories/src/types/search_history_repository.dart';
import 'package:boorusama/core/search/queries/tag_query_composer.dart';
import 'package:boorusama/core/search/selected_tags/types.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/core/settings/src/types/settings_repository.dart';
import 'package:boorusama/core/tags/autocompletes/autocomplete_repository.dart';
import 'package:boorusama/core/tags/favorites/types.dart';
import 'package:boorusama/core/tags/tag/types.dart';
import 'package:boorusama/foundation/filesystem.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/pincode/pincode.dart';
import 'package:boorusama/foundation/url_launcher.dart';

import '../../support/boorusama_test_runtime.dart';
import '../../support/fakes/test_post.dart';

export '../../support/fakes/test_post.dart';

final class FakeBooruPostRequest {
  FakeBooruPostRequest({
    required this.id,
    required this.siteUrl,
    required this.tags,
    required this.query,
    required this.page,
    required this.limit,
    this.resultIds = const [],
  });

  final int id;
  final String siteUrl;
  final List<String> tags;
  final String query;
  final int page;
  final int? limit;
  List<int> resultIds;
  var completed = false;
  BooruError? error;

  bool get pending => !completed;
}

sealed class FakeBooruPostResponse {
  const FakeBooruPostResponse();

  Future<Either<BooruError, PostResult<Post>>> resolve();
}

final class FakeBooruPostSuccess extends FakeBooruPostResponse {
  const FakeBooruPostSuccess(this.result);

  final PostResult<Post> result;

  @override
  Future<Either<BooruError, PostResult<Post>>> resolve() async =>
      Either.of(result);
}

final class FakeBooruPostFailure extends FakeBooruPostResponse {
  const FakeBooruPostFailure(this.error);

  final BooruError error;

  @override
  Future<Either<BooruError, PostResult<Post>>> resolve() async =>
      Either.left(error);
}

final class FakeBooruPostGate extends FakeBooruPostResponse {
  final _completer = Completer<Either<BooruError, PostResult<Post>>>();

  bool get isCompleted => _completer.isCompleted;

  void completeSuccess(PostResult<Post> result) =>
      _completer.complete(Either.of(result));

  void completeFailure(BooruError error) =>
      _completer.complete(Either.left(error));

  void cancelWithFailure([String message = 'Test gate canceled']) {
    if (!_completer.isCompleted) {
      completeFailure(
        UnknownError(error: StateError(message), message: message),
      );
    }
  }

  @override
  Future<Either<BooruError, PostResult<Post>>> resolve() => _completer.future;
}

typedef _PostRequestKey = ({String siteUrl, String query, int page});

enum FakeSiteValidation { reachable, emptyResults, unreachable }

final class FakeSiteValidationRequest {
  const FakeSiteValidationRequest(this.siteUrl);

  final String siteUrl;
}

/// Danbooru engine metadata restricted to synthetic hosts, so URL detection
/// in tests never resolves to a real site.
const _testDanbooruYaml = BooruYamlConfig(
  name: 'danbooru',
  type: BooruType.danbooru,
  protocol: NetworkProtocol.https_2_0,
  sites: [
    SiteConfig(url: FakeBooruBackend.siteUrl),
    SiteConfig(url: FakeBooruBackend.siteUrlB),
    SiteConfig(url: FakeBooruBackend.secondSiteUrl),
  ],
);

final class FakeBooruDetailsRequest {
  const FakeBooruDetailsRequest(this.id);

  final int id;
}

final class FakeBooruBackend {
  FakeBooruBackend({this.strictPostScripts = false})
    : config = BooruConfig.defaultConfig(
        booruType: BooruType.danbooru,
        url: siteUrl,
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
      'url': siteUrlB,
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
        parser: DefaultBooruParser(config: _testDanbooruYaml),
        createBuilder: _FakeBooruBuilder.new,
        createRepository: (ref) => _FakeBooruRepository(
          ref: ref,
          backend: this,
        ),
      ),
    );
  }

  static const siteUrl = 'https://headless.booru.test/';
  static const siteUrlB = 'https://headless-b.booru.test/';

  /// A recognized site with no seeded profile, used for profile creation.
  static const secondSiteUrl = 'https://second.booru.test/';

  final BooruConfig config;
  final List<TestPost> posts;
  final bool strictPostScripts;
  late final BooruConfig configB;
  late final List<TestPost> postsB;
  final requests = <Object>[];
  final postCompletions = <int>[];
  final pendingPostGates = <FakeBooruPostGate>[];
  final unexpectedPostRequests = <FakeBooruPostRequest>[];
  final siteValidations = <FakeSiteValidationRequest>[];
  final Map<String, Queue<FakeSiteValidation>> _siteValidationScripts = {};
  final Map<_PostRequestKey, Queue<FakeBooruPostResponse>> _postScripts = {};
  var _nextRequestId = 1;
  final registry = BooruRegistry();

  BooruDb get booruDb => BooruDb(
    boorus: {
      // Core widgets look up Danbooru-only data for this type, as in the app.
      BooruType.danbooru: const Danbooru(
        config: _testDanbooruYaml,
        sites: [],
      ),
    },
  );

  BoorusamaRuntime createRuntime({
    AppPlatform platform = AppPlatform.unknown,
    Settings? settings,
    List<BooruConfig>? configs,
    BooruConfig? initialConfig,
    BookmarkRepository? bookmarkRepository,
    GlobalBlacklistedTagRepository? globalBlacklistedTagRepository,
    SettingsRepository? settingsRepository,
    BooruConfigRepository? booruConfigRepository,
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
      platform: platform,
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
      globalBlacklistedTagRepository: globalBlacklistedTagRepository,
      settingsRepository: settingsRepository,
      booruConfigRepository: booruConfigRepository,
      downloadService: downloadService,
      favoriteTagRepository: favoriteTagRepository,
      searchHistoryRepository: searchHistoryRepository,
      appFilePicker: appFilePicker,
      fileSystem: fileSystem,
      externalUrlLauncher: externalUrlLauncher,
      pinCredentialRepositoryFactory: pinCredentialRepositoryFactory,
    );
  }

  void enqueuePostResponse({
    required String siteUrl,
    required String query,
    required int page,
    required FakeBooruPostResponse response,
  }) {
    final key = (siteUrl: siteUrl, query: query, page: page);
    (_postScripts[key] ??= Queue<FakeBooruPostResponse>()).add(response);
    if (response case final FakeBooruPostGate gate) pendingPostGates.add(gate);
  }

  void enqueuePostSuccess({
    required String siteUrl,
    required String query,
    required int page,
    required PostResult<Post> result,
  }) => enqueuePostResponse(
    siteUrl: siteUrl,
    query: query,
    page: page,
    response: FakeBooruPostSuccess(result),
  );

  void enqueuePostFailure({
    required String siteUrl,
    required String query,
    required int page,
    required BooruError error,
  }) => enqueuePostResponse(
    siteUrl: siteUrl,
    query: query,
    page: page,
    response: FakeBooruPostFailure(error),
  );

  /// Queues a successful page for the listing identified by [siteUrl] (the
  /// primary profile by default), [query] and [page].
  void enqueuePosts({
    required int page,
    required List<Post> posts,
    String? siteUrl,
    String query = '',
    int maxPage = 1,
  }) => enqueuePostSuccess(
    siteUrl: siteUrl ?? config.url,
    query: query,
    page: page,
    result: testPostResult(posts, maxPage: maxPage),
  );

  /// Queues the outcome of the next connection check for [siteUrl]. Unscripted
  /// checks report the site as reachable.
  void enqueueSiteValidation(String siteUrl, FakeSiteValidation outcome) =>
      (_siteValidationScripts[siteUrl] ??= Queue()).add(outcome);

  Future<bool> validateSite(String siteUrl) async {
    siteValidations.add(FakeSiteValidationRequest(siteUrl));
    final outcome = switch (_siteValidationScripts[siteUrl]) {
      final queue? when queue.isNotEmpty => queue.removeFirst(),
      _ => FakeSiteValidation.reachable,
    };
    return switch (outcome) {
      FakeSiteValidation.reachable => true,
      FakeSiteValidation.emptyResults => false,
      FakeSiteValidation.unreachable => throw StateError(
        'Fake connection check could not reach $siteUrl',
      ),
    };
  }

  FakeBooruPostGate enqueuePostGate({
    required String siteUrl,
    required String query,
    required int page,
  }) {
    final gate = FakeBooruPostGate();
    enqueuePostResponse(
      siteUrl: siteUrl,
      query: query,
      page: page,
      response: gate,
    );
    return gate;
  }

  Future<Either<BooruError, PostResult<Post>>> dispatchPosts({
    required String siteUrl,
    required String query,
    required List<String> tags,
    required int page,
    required int? limit,
  }) async {
    final request = _startPostRequest(
      siteUrl: siteUrl,
      query: query,
      tags: tags,
      page: page,
      limit: limit,
    );
    final key = (siteUrl: siteUrl, query: query, page: page);
    final queue = _postScripts[key];

    if (queue == null || queue.isEmpty) {
      if (strictPostScripts) {
        unexpectedPostRequests.add(request);
        final error = UnknownError(
          error: StateError('No scripted response for $key'),
          message: 'No scripted response for $key (request #${request.id})',
        );
        _completePostRequest(request, error: error);
        return Either.left(error);
      }

      final result = _defaultPostResult(
        siteUrl: siteUrl,
        tags: tags,
        page: page,
      );
      _completePostRequest(request, result: result);
      return Either.of(result);
    }

    final response = queue.removeFirst();
    if (queue.isEmpty) _postScripts.remove(key);
    final result = await response.resolve();
    result.fold(
      (error) => _completePostRequest(request, error: error),
      (value) => _completePostRequest(request, result: value),
    );
    return result;
  }

  PostsOrError<Post> createPostsTask({
    required String siteUrl,
    required String query,
    required List<String> tags,
    required int page,
    int? limit,
  }) => TaskEither(
    () => dispatchPosts(
      siteUrl: siteUrl,
      query: query,
      tags: tags,
      page: page,
      limit: limit,
    ),
  );

  /// Fails the test when strict mode answered a request nobody scripted.
  void expectNoUnexpectedPostRequests() {
    if (unexpectedPostRequests.isEmpty) return;
    throw TestFailure(
      'Unscripted post requests: ${unexpectedPostRequests.map(
        (r) => '#${r.id} ${r.siteUrl} q="${r.query}" p=${r.page}',
      ).join(', ')}',
    );
  }

  void cancelPendingPostGates() {
    for (final gate in pendingPostGates) {
      gate.cancelWithFailure();
    }
    pendingPostGates.clear();
  }

  FakeBooruPostRequest _startPostRequest({
    required String siteUrl,
    required String query,
    required List<String> tags,
    required int page,
    int? limit,
  }) {
    final request = FakeBooruPostRequest(
      id: _nextRequestId++,
      siteUrl: siteUrl,
      tags: List.unmodifiable(tags),
      query: query,
      page: page,
      limit: limit,
    );
    requests.add(request);
    return request;
  }

  void _completePostRequest(
    FakeBooruPostRequest request, {
    PostResult<Post>? result,
    BooruError? error,
  }) {
    request
      ..completed = true
      ..error = error
      ..resultIds = result?.posts.map((post) => post.id).toList() ?? const [];
    postCompletions.add(request.id);
  }

  PostResult<Post> _defaultPostResult({
    required String siteUrl,
    required List<String> tags,
    required int page,
  }) {
    final matchingPosts = page == 1
        ? _filterPosts(tags, siteUrl: siteUrl)
        : <TestPost>[];
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
      () => backend.validateSite(config.url);
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
  }) => backend.createPostsTask(
    siteUrl: config.auth.url,
    query: tags,
    tags: tags.isEmpty ? const [] : tags.split(' '),
    page: page,
    limit: limit,
  );

  @override
  PostsOrError<Post> getPostsFromController(
    SearchTagSet controller,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) {
    final tags = List<String>.unmodifiable(controller.rawTags);
    return backend.createPostsTask(
      siteUrl: config.auth.url,
      query: tags.join(' '),
      tags: tags,
      page: page,
      limit: limit,
    );
  }

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

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const _FakeFavoritesPage();

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => _FakeArtistPage(artistName: artistName);

  // Engines without character data reuse the artist page.
  @override
  CharacterPageBuilder? get characterPageBuilder =>
      (context, characterName) => _FakeArtistPage(artistName: characterName);
}

class _FakeFavoritesPage extends ConsumerWidget {
  const _FakeFavoritesPage();

  static const _query = 'fav:tester';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(postRepoProvider(ref.watchConfigSearch));

    return FavoritesPageScaffold(
      favQueryBuilder: () => _query,
      fetcher: (page) => repo.getPosts(_query, page),
    );
  }
}

class _FakeArtistPage extends ConsumerWidget {
  const _FakeArtistPage({required this.artistName});

  final String artistName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(postRepoProvider(ref.watchConfigSearch));

    return ArtistPageScaffold(
      artistName: artistName,
      fetcher: (page, category) => repo.getPosts(
        queryFromTagFilterCategory(
          category: category,
          tag: artistName,
          builder: (category) => category == TagFilterCategory.popular
              ? some('order:score')
              : none(),
        ),
        page,
      ),
    );
  }
}
