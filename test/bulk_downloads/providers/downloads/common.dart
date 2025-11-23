// Package imports:
import 'package:background_downloader/background_downloader.dart'
    hide Database, PermissionStatus;

// Package imports:
import 'package:dio/dio.dart';
import 'package:filename_generator/filename_generator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/core/analytics/providers.dart';
import 'package:boorusama/core/blacklists/providers.dart';
import 'package:boorusama/core/boorus/booru/types.dart';
import 'package:boorusama/core/boorus/engine/providers.dart';
import 'package:boorusama/core/boorus/engine/types.dart';
import 'package:boorusama/core/bulk_downloads/providers.dart';
import 'package:boorusama/core/bulk_downloads/src/notifications/bulk_download_notification.dart';
import 'package:boorusama/core/bulk_downloads/src/notifications/providers.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_configs.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_options.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_repository.dart';
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/configs/manage/providers.dart';
import 'package:boorusama/core/ddos/handler/providers.dart';
import 'package:boorusama/core/download_manager/providers.dart';
import 'package:boorusama/core/downloads/downloader/providers.dart';
import 'package:boorusama/core/downloads/downloader/types.dart' as d;
import 'package:boorusama/core/downloads/filename/providers.dart';
import 'package:boorusama/core/downloads/filename/types.dart';
import 'package:boorusama/core/downloads/urls/providers.dart';
import 'package:boorusama/core/posts/post/providers.dart';
import 'package:boorusama/core/posts/post/types.dart';
import 'package:boorusama/core/premiums/providers.dart';
import 'package:boorusama/core/search/queries/types.dart';
import 'package:boorusama/core/search/selected_tags/types.dart';
import 'package:boorusama/core/settings/providers.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/foundation/info/device_info.dart';
import 'package:boorusama/foundation/loggers.dart';
import 'package:boorusama/foundation/permissions.dart';
import '../../common.dart';

class MockMediaPermissionManager extends Mock
    implements MediaPermissionManager {}

class DummyLogger implements Logger {
  const DummyLogger();

  @override
  String getDebugName() => 'Dummy Logger';

  @override
  void error(String serviceName, String message) {}

  @override
  void info(String serviceName, String message) {}

  @override
  void warn(String serviceName, String message) {}

  @override
  void verbose(String serviceName, String message) {}

  @override
  void debug(String serviceName, String message) {}
}

class DownloadTestConstants {
  static const perPage = 2;
  static final lastPage = (posts.length / perPage).ceil();

  static final defaultOptions = DownloadOptions(
    path: '/storage/emulated/0/Download',
    notifications: true,
    skipIfExists: true,
    perPage: 2,
    concurrency: 5,
    tags: SearchTagSet.fromList(const ['test_tags']),
  );

  static const defaultConfigs = DownloadConfigs(
    delayBetweenDownloads: Duration.zero,
    delayBetweenRequests: Duration(milliseconds: 5),
    directoryExistChecker: AlwaysExistsDirectoryExistChecker(),
  );

  static final defaultAuthConfig = booruConfigAuth;

  static final posts = [
    // page 1
    DummyPost(
      id: 1,
      thumbnailImageUrl: 'test-thumbnail-url-1',
      originalImageUrl: 'test-original-url-1',
      sampleImageUrl: 'test-sample-url-1',
      tags: {'tag1', 'tag2'},
    ),
    DummyPost(
      id: 2,
      thumbnailImageUrl: 'test-thumbnail-url-2',
      originalImageUrl: 'test-original-url-2',
      sampleImageUrl: 'test-sample-url-2',
      tags: {'tag3', 'tag4'},
    ),
    // page 2
    DummyPost(
      id: 3,
      thumbnailImageUrl: 'test-thumbnail-url-3',
      originalImageUrl: 'test-original-url-3',
      sampleImageUrl: 'test-sample-url-3',
      tags: {'tag5', 'tag6'},
    ),
    DummyPost(
      id: 4,
      thumbnailImageUrl: 'test-thumbnail-url-4',
      originalImageUrl: 'test-original-url-4',
      sampleImageUrl: 'test-sample-url-4',
      tags: {'tag7'},
    ),
    // page 3
    DummyPost(
      id: 5,
      thumbnailImageUrl: 'test-thumbnail-url-5',
      originalImageUrl: 'test-original-url-5',
      sampleImageUrl: 'test-sample-url-5',
      tags: {'tag8'},
    ),
    DummyPost(
      id: 6,
      thumbnailImageUrl: 'test-thumbnail-url-6',
      originalImageUrl: 'test-original-url-6',
      sampleImageUrl: 'test-sample-url-6',
      tags: {'tag9'},
    ),
    // page 4
    DummyPost(
      id: 7,
      thumbnailImageUrl: 'test-thumbnail-url-7',
      originalImageUrl: 'test-original-url-7',
      sampleImageUrl: 'test-sample-url-7',
      tags: {'tag10'},
    ),
  ];
}

class DummyPostRepository implements PostRepository {
  @override
  PostsOrError<Post> getPosts(
    String tags,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) {
    final posts = DownloadTestConstants.posts
        .skip((page - 1) * DownloadTestConstants.perPage)
        .take(DownloadTestConstants.perPage)
        .toList();

    return TaskEither.right(PostResult(posts: posts, total: null));
  }

  @override
  PostsOrError<Post> getPostsFromController(
    SearchTagSet controller,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) => getPosts('', page);

  @override
  PostOrError<Post> getPost(PostId id, {PostFetchOptions? options}) {
    final numericId = id as NumericPostId?;

    if (numericId == null) return TaskEither.right(null);

    final post = DownloadTestConstants.posts.firstWhere(
      (element) => element.id == numericId.value,
    );

    return TaskEither.right(post);
  }

  @override
  TagQueryComposer get tagComposer =>
      DefaultTagQueryComposer(config: booruConfigSearch);
}

final booruConfigSearch = BooruConfigSearch.fromConfig(
  booruConfig,
);

final booruConfigAuth = BooruConfigAuth.fromConfig(
  booruConfig,
);

final booruConfig = BooruConfig.defaultConfig(
  booruType: BooruType.danbooru,
  url: 'test-url',
  customDownloadFileNameFormat: null,
);

class MockBooruBuilder extends Mock implements BooruBuilder {}

class DummyBulkNotification implements BulkDownloadNotifications {
  @override
  Future<void> cancelNotification(String sessionId) async {}

  @override
  void dispose() {}

  @override
  Future<void> showNotification(
    String title,
    String body, {
    String? payload,
    int? progress,
    int? total,
    bool? indeterminate,
    int? notificationId,
  }) async {}

  @override
  Future<void> showCompleteNotification(
    String title,
    String body, {
    required int notificationId,
    String? payload,
  }) async {}

  @override
  Future<void> showProgressNotification(
    String sessionId,
    String title,
    String body, {
    required int completed,
    required int total,
  }) async {}

  @override
  Stream<String> get tapStream => const Stream.empty();
}

class DummyDownloadService implements d.DownloadService {
  @override
  Future<d.DownloadResult> download(d.DownloadOptions options) async {
    return d.DownloadSuccess(
      d.DownloadTaskInfo(
        path: 'path',
        id: options.url,
      ),
    );
  }

  @override
  Future<bool> cancelAll(String group) {
    return Future.value(true);
  }

  @override
  Future<void> pauseAll(String group) async {}

  @override
  Future<void> resumeAll(String group) async {}
}

final dummyDownloadFileNameBuilder = DownloadFileNameBuilder<DummyPost>(
  tokenHandlers: const [],
  sampleData: const [],
  defaultFileNameFormat: 'test-default-format',
  defaultBulkDownloadFileNameFormat: 'test-default-bulk-format',
);

class AlwaysExistsDirectoryExistChecker implements DirectoryExistChecker {
  const AlwaysExistsDirectoryExistChecker();
  @override
  bool exists(String path) => true;
}

class AlwaysNotExistsDirectoryExistChecker implements DirectoryExistChecker {
  const AlwaysNotExistsDirectoryExistChecker();
  @override
  bool exists(String path) => false;
}

class AlwaysGrantedPermissionManager implements MediaPermissionManager {
  @override
  Future<PermissionStatus> check() async => PermissionStatus.granted;

  @override
  Future<PermissionStatus> request() async => PermissionStatus.granted;

  @override
  DeviceInfo get deviceInfo => DeviceInfo.empty();
}

class AlwaysGrantedNotificationPermissionManager
    implements NotificationPermissionManager {
  @override
  Logger logger = const DummyLogger();

  @override
  Future<PermissionStatus> check() async => PermissionStatus.granted;

  @override
  Future<PermissionStatus> request() async => PermissionStatus.granted;

  @override
  PermissionStatus? get status => PermissionStatus.granted;

  @override
  set status(PermissionStatus? status) {}

  @override
  Future<void> requestIfNotGranted() async {}
}

class ExistCheckerMock extends Mock implements DownloadExistChecker {}

const emptyTaskUpdateStream = Stream<TaskUpdate>.empty();

ProviderContainer createBulkDownloadContainer({
  required DownloadRepository downloadRepository,
  required MockBooruBuilder booruBuilder,
  MediaPermissionManager? mediaPermissionManager,
  bool hasPremium = true,
  Stream<TaskUpdate>? taskUpdateStream,
  BooruConfigAuth? overrideConfig,
}) {
  final container = ProviderContainer(
    overrides: getTestOverrides(
      downloadRepository: downloadRepository,
      mediaPermissionManager:
          mediaPermissionManager ?? AlwaysGrantedPermissionManager(),
      booruBuilder: booruBuilder,
      notifications: DummyBulkNotification(),
      hasPremium: hasPremium,
      taskUpdateStream: taskUpdateStream,
      overrideConfig: overrideConfig,
    ),
  );

  addTearDown(() {
    reset(booruBuilder);
    container.dispose();
  });

  return container;
}

List<Override> getTestOverrides({
  required DownloadRepository downloadRepository,
  MediaPermissionManager? mediaPermissionManager,
  BooruBuilder? booruBuilder,
  BulkDownloadNotifications? notifications,
  bool hasPremium = true,
  Stream<TaskUpdate>? taskUpdateStream,
  BooruConfigAuth? overrideConfig,
}) {
  return [
    internalDownloadRepositoryProvider.overrideWith((_) => downloadRepository),
    currentReadOnlyBooruConfigSearchProvider.overrideWithValue(
      booruConfigSearch,
    ),
    currentReadOnlyBooruConfigAuthProvider.overrideWithValue(
      overrideConfig ?? booruConfigAuth,
    ),
    currentReadOnlyBooruConfigProvider.overrideWithValue(booruConfig),
    postRepoProvider.overrideWith((_, _) => DummyPostRepository()),
    downloadServiceProvider.overrideWith((_) => DummyDownloadService()),
    downloadFilenameBuilderProvider.overrideWith(
      (_, _) => dummyDownloadFileNameBuilder,
    ),
    loggerProvider.overrideWithValue(const DummyLogger()),
    mediaPermissionManagerProvider.overrideWithValue(
      mediaPermissionManager ?? MockMediaPermissionManager(),
    ),
    notificationPermissionManagerProvider.overrideWithValue(
      AlwaysGrantedNotificationPermissionManager(),
    ),
    settingsProvider.overrideWithValue(Settings.defaultSettings),
    downloadFileUrlExtractorProvider.overrideWith(
      (_, _) => const UrlInsidePostExtractor(),
    ),
    cachedBypassDdosHeadersProvider.overrideWith((_, _) => {}),
    analyticsProvider.overrideWith((_) => NoAnalyticsInterface()),
    booruBuilderProvider.overrideWith(
      (_, _) => booruBuilder ?? MockBooruBuilder(),
    ),
    blacklistTagsProvider.overrideWith((_, _) => {}),
    hasPremiumProvider.overrideWithValue(hasPremium),
    downloadTaskStreamProvider.overrideWith(
      (_) => taskUpdateStream ?? emptyTaskUpdateStream,
    ),
    taskFileSizeResolverProvider.overrideWith((_, _) => Future.value(0)),
    if (notifications != null)
      bulkDownloadNotificationProvider.overrideWith((_) => notifications),
  ];
}

class MockAsyncFilenameBuilder implements DownloadFilenameGenerator<DummyPost> {
  MockAsyncFilenameBuilder({
    this.hasAsyncTokens = false,
    this.preloadResult = const Sync(),
    this.shouldFailGenerate = false,
    this.shouldFailPreload = false,
  });

  final bool hasAsyncTokens;
  final PreloadResult preloadResult;
  final bool shouldFailGenerate;
  final bool shouldFailPreload;

  final List<DummyPost> generatedPosts = [];
  final List<List<DummyPost>> preloadedChunks = [];
  var preloadCallCount = 0;

  @override
  Future<String> generateForBulkDownload(
    Settings settings,
    BooruConfigDownload config,
    DummyPost post, {
    required String downloadUrl,
    Map<String, String>? metadata,
    CancelToken? cancelToken,
    Duration? asyncTokenDelay,
  }) async {
    generatedPosts.add(post);

    if (cancelToken?.isCancelled ?? false) {
      throw DioException(requestOptions: RequestOptions());
    }

    if (shouldFailGenerate) {
      throw Exception('Generate failed');
    }

    if (asyncTokenDelay != null) {
      await Future.delayed(asyncTokenDelay);
    }

    final index = metadata?['index'] ?? '0';
    return 'file_${post.id}_$index.jpg';
  }

  @override
  Future<PreloadResult> preloadForBulkDownload(
    List<DummyPost> posts,
    BooruConfigAuth config,
    BooruConfigDownload downloadConfig,
    CancelToken? cancelToken,
  ) async {
    preloadCallCount++;
    preloadedChunks.add(List.from(posts));

    if (shouldFailPreload) {
      throw Exception('Preload failed');
    }

    return preloadResult;
  }

  @override
  bool formatContainsAsyncToken(String? format) => hasAsyncTokens;

  @override
  bool hasSlowBulkGeneration(String format) => false;
  @override
  List<TokenInfo> get availableTokens => [];
  @override
  List<TextMatcher> get textMatchers => [];
  @override
  List<String> getTokenOptions(String token) => [];
  @override
  TokenOptionDocs? getDocsForTokenOption(String token, String tokenOption) =>
      null;
  @override
  Future<String> generate(
    Settings settings,
    BooruConfigDownload config,
    DummyPost post, {
    required String downloadUrl,
    Map<String, String>? metadata,
    CancelToken? cancelToken,
  }) async => 'test.jpg';
  @override
  String generateSample(String format) => 'sample.jpg';
  @override
  List<String> generateSamples(String format) => ['sample.jpg'];
  @override
  String get defaultFileNameFormat => '{id}.{extension}';
  @override
  String get defaultBulkDownloadFileNameFormat => '{index}_{id}.{extension}';
}
