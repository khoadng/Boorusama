// ignore_for_file: avoid_returning_this

import 'package:boorusama/core/blacklists/types.dart';
import 'package:boorusama/core/boorus/booru/types.dart';
import 'package:boorusama/core/boorus/engine/types.dart';
import 'package:boorusama/core/bookmarks/types.dart';
import 'package:boorusama/core/bootstrap/boorusama_runtime.dart';
import 'package:boorusama/core/downloads/downloader/types.dart';
import 'package:boorusama/core/search/histories/src/types/search_history_repository.dart';
import 'package:boorusama/core/search/histories/src/types/search_history_repository_factory.dart';
import 'package:boorusama/core/configs/config/src/types/booru_config_repository.dart';
import 'package:boorusama/core/settings/src/types/settings_repository.dart';
import 'package:boorusama/core/tags/favorites/types.dart';
import 'package:boorusama/foundation/applock/src/device_authenticator.dart';
import 'package:boorusama/foundation/filesystem.dart';
import 'package:boorusama/foundation/networking/connectivity_service.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/pincode/pincode.dart';
import 'package:boorusama/foundation/webview_user_agent.dart';
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/core/http/cookies/providers.dart';

import '../boorusama_test_runtime.dart';

/// Fluent construction for tests that need to replace one runtime boundary.
/// Unset fields are recreated by [build] on every call.
final class TestBoorusamaRuntimeBuilder {
  AppPlatform _platform = AppPlatform.unknown;
  ConnectivityService? _connectivityService;
  DeviceAuthenticator? _deviceAuthenticator;
  PinCredentialRepositoryFactory? _pinCredentialRepositoryFactory;
  WebViewUserAgentService? _webViewUserAgentService;
  CookieJarFactory? _cookieJarFactory;
  AppFilePicker? _appFilePicker;
  ExternalUrlLauncher? _externalUrlLauncher;
  AppFileSystem? _fileSystem;
  BoorusamaInitialState? _initialState;
  BooruDb? _booruDb;
  BooruRegistry? _booruRegistry;
  BookmarkRepository? _bookmarkRepository;
  BookmarkRepositoryFactory? _bookmarkRepositoryFactory;
  GlobalBlacklistedTagRepository? _globalBlacklistedTagRepository;
  GlobalBlacklistedTagRepositoryFactory? _globalBlacklistedTagRepositoryFactory;
  DownloadService? _downloadService;
  DownloadServiceFactory? _downloadServiceFactory;
  FavoriteTagRepository? _favoriteTagRepository;
  FavoriteTagRepositoryFactory? _favoriteTagRepositoryFactory;
  SearchHistoryRepository? _searchHistoryRepository;
  SearchHistoryRepositoryFactory? _searchHistoryRepositoryFactory;
  SettingsRepository? _settingsRepository;
  BooruConfigRepository? _booruConfigRepository;

  TestBoorusamaRuntimeBuilder withPlatform(AppPlatform value) {
    _platform = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withConnectivity(
    ConnectivityService value,
  ) {
    _connectivityService = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withDeviceAuthenticator(
    DeviceAuthenticator value,
  ) {
    _deviceAuthenticator = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withPinCredentialRepositoryFactory(
    PinCredentialRepositoryFactory value,
  ) {
    _pinCredentialRepositoryFactory = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withWebViewUserAgentService(
    WebViewUserAgentService value,
  ) {
    _webViewUserAgentService = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withCookieJarFactory(CookieJarFactory value) {
    _cookieJarFactory = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withFilePicker(AppFilePicker value) {
    _appFilePicker = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withExternalUrlLauncher(
    ExternalUrlLauncher value,
  ) {
    _externalUrlLauncher = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withFileSystem(AppFileSystem value) {
    _fileSystem = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withInitialState(BoorusamaInitialState value) {
    _initialState = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withBooruDb(BooruDb value) {
    _booruDb = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withBooruRegistry(BooruRegistry value) {
    _booruRegistry = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withBookmarkRepository(
    BookmarkRepository value,
  ) {
    _bookmarkRepository = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withBookmarkRepositoryFactory(
    BookmarkRepositoryFactory value,
  ) {
    _bookmarkRepositoryFactory = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withBlacklistRepository(
    GlobalBlacklistedTagRepository value,
  ) {
    _globalBlacklistedTagRepository = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withBlacklistRepositoryFactory(
    GlobalBlacklistedTagRepositoryFactory value,
  ) {
    _globalBlacklistedTagRepositoryFactory = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withDownloadService(DownloadService value) {
    _downloadService = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withDownloadServiceFactory(
    DownloadServiceFactory value,
  ) {
    _downloadServiceFactory = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withFavoriteTagRepository(
    FavoriteTagRepository value,
  ) {
    _favoriteTagRepository = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withFavoriteTagRepositoryFactory(
    FavoriteTagRepositoryFactory value,
  ) {
    _favoriteTagRepositoryFactory = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withSearchHistoryRepository(
    SearchHistoryRepository value,
  ) {
    _searchHistoryRepository = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withSearchHistoryRepositoryFactory(
    SearchHistoryRepositoryFactory value,
  ) {
    _searchHistoryRepositoryFactory = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withSettingsRepository(
    SettingsRepository value,
  ) {
    _settingsRepository = value;
    return this;
  }

  TestBoorusamaRuntimeBuilder withBooruConfigRepository(
    BooruConfigRepository value,
  ) {
    _booruConfigRepository = value;
    return this;
  }

  BoorusamaRuntime build() => createTestBoorusamaRuntime(
    platform: _platform,
    connectivityService: _connectivityService,
    deviceAuthenticator: _deviceAuthenticator,
    pinCredentialRepositoryFactory: _pinCredentialRepositoryFactory,
    webViewUserAgentService: _webViewUserAgentService,
    cookieJarFactory: _cookieJarFactory,
    appFilePicker: _appFilePicker,
    externalUrlLauncher: _externalUrlLauncher,
    fileSystem: _fileSystem,
    initialState: _initialState,
    booruDb: _booruDb,
    booruRegistry: _booruRegistry,
    bookmarkRepository: _bookmarkRepository,
    bookmarkRepositoryFactory: _bookmarkRepositoryFactory,
    globalBlacklistedTagRepository: _globalBlacklistedTagRepository,
    globalBlacklistedTagRepositoryFactory:
        _globalBlacklistedTagRepositoryFactory,
    downloadService: _downloadService,
    downloadServiceFactory: _downloadServiceFactory,
    favoriteTagRepository: _favoriteTagRepository,
    favoriteTagRepositoryFactory: _favoriteTagRepositoryFactory,
    searchHistoryRepository: _searchHistoryRepository,
    searchHistoryRepositoryFactory: _searchHistoryRepositoryFactory,
    settingsRepository: _settingsRepository,
    booruConfigRepository: _booruConfigRepository,
  );
}
