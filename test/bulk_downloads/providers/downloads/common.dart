// Package imports:
import 'package:background_downloader/background_downloader.dart'
    hide Database, PermissionStatus;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/core/analytics.dart';
import 'package:boorusama/core/blacklists/providers.dart';
import 'package:boorusama/core/boorus/booru/booru.dart';
import 'package:boorusama/core/boorus/engine/engine.dart';
import 'package:boorusama/core/boorus/engine/providers.dart';
import 'package:boorusama/core/bulk_downloads/src/data/download_repository_provider.dart';
import 'package:boorusama/core/bulk_downloads/src/notifications/bulk_download_notification.dart';
import 'package:boorusama/core/bulk_downloads/src/notifications/providers.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_configs.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_options.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_repository.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/current.dart';
import 'package:boorusama/core/downloads/downloader.dart';
import 'package:boorusama/core/downloads/filename.dart';
import 'package:boorusama/core/downloads/manager.dart';
import 'package:boorusama/core/downloads/urls.dart';
import 'package:boorusama/core/foundation/loggers.dart';
import 'package:boorusama/core/foundation/permissions.dart';
import 'package:boorusama/core/http/providers.dart';
import 'package:boorusama/core/info/device_info.dart';
import 'package:boorusama/core/posts/post/post.dart';
import 'package:boorusama/core/posts/post/providers.dart';
import 'package:boorusama/core/premiums/providers.dart';
import 'package:boorusama/core/search/queries/query.dart';
import 'package:boorusama/core/search/selected_tags/providers.dart';
import 'package:boorusama/core/search/selected_tags/tag.dart';
import 'package:boorusama/core/settings/providers.dart';
import 'package:boorusama/core/settings/settings.dart';
import '../../common.dart';

class MockMediaPermissionManager extends Mock
    implements MediaPermissionManager {}

class DummyLogger implements Logger {
  @override
  void log(String serviceName, String message, {LogLevel? level}) {}

  @override
  void logE(String serviceName, String message) {}

  @override
  void logI(String serviceName, String message) {}

  @override
  void logW(String serviceName, String message) {}
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
  PostsOrError<Post> getPosts(String tags, int page, {int? limit}) {
    final posts = DownloadTestConstants.posts
        .skip((page - 1) * DownloadTestConstants.perPage)
        .take(DownloadTestConstants.perPage)
        .toList();

    return TaskEither.right(PostResult(posts: posts, total: null));
  }

  @override
  PostsOrError<Post> getPostsFromController(
    SelectedTagController controller,
    int page, {
    int? limit,
  }) =>
      getPosts('', page);

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

class DummyDownloadService implements DownloadService {
  @override
  DownloadTaskInfoOrError download({
    required String url,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  }) {
    return TaskEither.right(
      DownloadTaskInfo(
        path: 'path',
        id: url,
      ),
    );
  }

  @override
  DownloadTaskInfoOrError downloadCustomLocation({
    required String url,
    required String path,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  }) {
    return TaskEither.right(
      DownloadTaskInfo(path: 'path', id: url),
    );
  }

  @override
  Future<bool> cancelTasksWithIds(List<String> ids) {
    return Future.value(true);
  }

  @override
  Future<void> pauseAll(String group) async {}

  @override
  Future<void> resumeAll(String group) async {}
}

final dummyDownloadFileNameBuilder = DownloadFileNameBuilder<DummyPost>(
  tokenHandlers: {},
  sampleData: [],
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
  when(() => booruBuilder.downloadFilenameBuilder).thenReturn(
    dummyDownloadFileNameBuilder,
  );

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
    currentReadOnlyBooruConfigSearchProvider
        .overrideWithValue(booruConfigSearch),
    currentReadOnlyBooruConfigAuthProvider.overrideWithValue(
      overrideConfig ?? booruConfigAuth,
    ),
    currentReadOnlyBooruConfigProvider.overrideWithValue(booruConfig),
    postRepoProvider.overrideWith((__, _) => DummyPostRepository()),
    downloadServiceProvider.overrideWith((_) => DummyDownloadService()),
    loggerProvider.overrideWithValue(DummyLogger()),
    mediaPermissionManagerProvider.overrideWithValue(
      mediaPermissionManager ?? MockMediaPermissionManager(),
    ),
    notificationPermissionManagerProvider.overrideWithValue(
      AlwaysGrantedNotificationPermissionManager(),
    ),
    settingsProvider.overrideWithValue(Settings.defaultSettings),
    downloadFileUrlExtractorProvider
        .overrideWith((__, _) => const UrlInsidePostExtractor()),
    cachedBypassDdosHeadersProvider.overrideWith((_, __) => {}),
    analyticsProvider.overrideWith((_) => NoAnalyticsInterface()),
    currentBooruBuilderProvider
        .overrideWith((_) => booruBuilder ?? MockBooruBuilder()),
    blacklistTagsProvider.overrideWith((_, __) => {}),
    hasPremiumProvider.overrideWithValue(hasPremium),
    downloadTaskStreamProvider
        .overrideWith((_) => taskUpdateStream ?? emptyTaskUpdateStream),
    taskFileSizeResolverProvider.overrideWith((_, __) => Future.value(0)),
    if (notifications != null)
      bulkDownloadNotificationProvider.overrideWith((_) => notifications),
  ];
}
