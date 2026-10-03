import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/foundation/platform.dart';

import '../../support/boorusama_test_runtime.dart';
import 'fake_booru_backend.dart';
import 'headless_app_harness.dart';

typedef _MountOptions = ({
  FakeBooruBackend backend,
  AppPlatform platform,
  Size? viewportSize,
  List<Override> additionalOverrides,
});

/// Memory-backed state shared only by the before/after apps in one flow test.
final class ApplicationTestStore {
  ApplicationTestStore({
    Settings? settings,
    Iterable<BooruConfig> configs = const [],
  }) : settingsRepository = MemorySettingsRepository(
         settings ?? Settings.defaultSettings,
       ),
       booruConfigRepository = MemoryBooruConfigRepository(configs: configs);

  /// Seeds [initial] as the selected profile followed by [additional] in the
  /// profile order.
  factory ApplicationTestStore.withProfiles(
    BooruConfig initial, {
    Iterable<BooruConfig> additional = const [],
  }) {
    final configs = [initial, ...additional];
    return ApplicationTestStore(
      settings: Settings.defaultSettings.copyWith(
        currentBooruConfigId: initial.id,
        booruConfigIdOrders: configs.map((config) => config.id).join(' '),
      ),
      configs: configs,
    );
  }

  final MemorySettingsRepository settingsRepository;
  final MemoryBooruConfigRepository booruConfigRepository;
  final bookmarkRepository = MemoryBookmarkRepository();
  final favoriteTagRepository = MemoryFavoriteTagRepository();
  final searchHistoryRepository = MemorySearchHistoryRepository();
  final globalBlacklistedTagRepository = MemoryGlobalBlacklistedTagRepository();

  _MountOptions? _lastMount;

  Settings get settings => settingsRepository.settings;
  List<BooruConfig> get configs => booruConfigRepository.configs;

  BooruConfig configWithId(int id) =>
      configs.singleWhere((config) => config.id == id);

  /// Boots an app from the persisted repositories using the production
  /// startup selection rule, and registers its teardown.
  Future<HeadlessAppHarness> mount(
    WidgetTester tester, {
    required FakeBooruBackend backend,
    AppPlatform platform = AppPlatform.android,
    Size? viewportSize,
    List<Override> additionalOverrides = const [],
  }) async {
    _lastMount = (
      backend: backend,
      platform: platform,
      viewportSize: viewportSize,
      additionalOverrides: additionalOverrides,
    );

    final settings = await _loadSettings();
    final configs = await booruConfigRepository.getAll();
    final initialConfig =
        await booruConfigRepository.getCurrentBooruConfigFrom(settings) ??
        BooruConfig.empty;

    final harness = HeadlessAppHarness(
      booruBackend: backend,
      viewportSize: viewportSize,
      additionalOverrides: additionalOverrides,
      runtime: backend.createRuntime(
        platform: platform,
        settings: settings,
        configs: configs,
        initialConfig: initialConfig,
        settingsRepository: settingsRepository,
        booruConfigRepository: booruConfigRepository,
        bookmarkRepository: bookmarkRepository,
        globalBlacklistedTagRepository: globalBlacklistedTagRepository,
        favoriteTagRepository: favoriteTagRepository,
        searchHistoryRepository: searchHistoryRepository,
      ),
    );
    addTearDown(() => harness.teardown(tester));
    await harness.pump(tester);
    return harness;
  }

  /// Unmounts [previous] and boots a fresh app with the same mount options.
  Future<HeadlessAppHarness> remount(
    WidgetTester tester, {
    required HeadlessAppHarness previous,
  }) async {
    final options = _lastMount;
    if (options == null) {
      throw StateError('remount requires a previous mount from this store');
    }

    await previous.teardown(tester);
    return mount(
      tester,
      backend: options.backend,
      platform: options.platform,
      viewportSize: options.viewportSize,
      additionalOverrides: options.additionalOverrides,
    );
  }

  Future<Settings> _loadSettings() async {
    final result = await settingsRepository.load().run();
    return result.fold(
      (error) => throw StateError('Stored settings failed to load: $error'),
      (settings) => settings,
    );
  }
}
