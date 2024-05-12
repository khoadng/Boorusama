// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import '../riverpod_test_utils.dart';

class InMemoryBooruConfigRepository implements BooruConfigRepository {
  final List<BooruConfig> _configs = [];

  @override
  Future<BooruConfig?> add(BooruConfigData booruConfigData) {
    final id = _configs.isEmpty ? 1 : _configs.last.id + 1;
    final config = booruConfigData.toBooruConfig(id: id);

    if (config == null) return Future.value(null);

    _configs.add(config);
    return Future.value(config);
  }

  @override
  Future<List<BooruConfig>> addAll(List<BooruConfig> booruConfigs) {
    final ids = _configs.map((e) => e.id).toList();
    final newConfigs = booruConfigs
        .map((e) {
          final data = e.toBooruConfigData();
          final id = ids.isEmpty ? 1 : ids.last + 1;
          return data.toBooruConfig(id: id);
        })
        .whereNotNull()
        .toList();

    _configs.addAll(newConfigs);

    return Future.value(newConfigs);
  }

  @override
  Future<void> clear() {
    _configs.clear();
    return Future.value();
  }

  @override
  Future<List<BooruConfig>> getAll() {
    return Future.value(_configs.toList());
  }

  @override
  Future<void> remove(BooruConfig booruConfig) {
    _configs.removeWhere((e) => e.id == booruConfig.id);
    return Future.value();
  }

  @override
  Future<BooruConfig?> update(int id, BooruConfigData booruConfigData) {
    final index = _configs.indexWhere((e) => e.id == id);
    if (index == -1) return Future.value(null);

    final config = booruConfigData.toBooruConfig(id: id);
    if (config == null) return Future.value(null);

    _configs[index] = config;
    return Future.value(config);
  }
}

class MockAnalytics extends Mock implements AnalyticsInterface {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockLogger extends Mock implements LoggerService {}

final mockAnalytics = MockAnalytics();

class MockCallback extends Mock {
  void call();
}

ProviderContainer createBooruConfigContainer({
  BooruConfigRepository? booruConfigRepository,
  SettingsRepository? settingsRepository,
}) {
  final mockSettingsRepository = MockSettingsRepository();
  final mockLogger = MockLogger();

  when(() => mockSettingsRepository.save(any())).thenAnswer((_) async => true);

  return createContainer(
    overrides: [
      booruConfigRepoProvider.overrideWith(
          (ref) => booruConfigRepository ?? InMemoryBooruConfigRepository()),
      settingsRepoProvider
          .overrideWithValue(settingsRepository ?? mockSettingsRepository),
      settingsProvider
          .overrideWith(() => SettingsNotifier(Settings.defaultSettings)),
      currentBooruConfigProvider.overrideWith(
          () => CurrentBooruConfigNotifier(initialConfig: BooruConfig.empty)),
      analyticsProvider.overrideWithValue(mockAnalytics),
      loggerProvider.overrideWithValue(mockLogger),
    ],
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(Settings.defaultSettings);
  });

  group(
    'Add a new config',
    () {
      final mockSettingsRepository = MockSettingsRepository();
      late ProviderContainer container;
      final configData = BooruConfig.empty.toBooruConfigData();

      BooruConfigNotifier getNotifier() =>
          container.read(booruConfigProvider.notifier);

      setUp(
        () async {
          reset(mockSettingsRepository);
          reset(mockAnalytics);

          when(() => mockSettingsRepository.save(any()))
              .thenAnswer((_) async => true);

          container = createBooruConfigContainer(
            settingsRepository: mockSettingsRepository,
          );

          await getNotifier().fetch();
        },
      );

      test(
        'should add a new config',
        () async {
          await getNotifier().add(
            data: configData,
          );

          final newData = container.read(booruConfigProvider);

          expect(
            listEquals(
              [configData.toBooruConfig(id: 1)],
              newData,
            ),
            isTrue,
          );
        },
      );

      test(
        'should call the success callback',
        () async {
          final successCallback = MockCallback();

          await getNotifier().add(
            data: configData,
            onSuccess: (booruConfig) => successCallback(),
          );

          verify(() => successCallback()).called(1);
        },
      );

      test(
        'should update order',
        () async {
          await getNotifier().add(
            data: configData,
          );

          verify(
            () => mockSettingsRepository.save(
              any(
                that: isA<Settings>().having(
                  (settings) => settings.booruConfigIdOrders,
                  'booruConfigIdOrders',
                  '1',
                ),
              ),
            ),
          ).called(1);
        },
      );

      // should update current booru config if set as current
      test(
        'should update current booru config if set as current',
        () async {
          await getNotifier().add(
            data: configData,
            setAsCurrent: true,
          );

          expect(
            container.read(currentBooruConfigProvider).id,
            1,
          );
        },
      );

      test(
        'should call the analytics',
        () async {
          await getNotifier().add(
            data: configData,
          );

          verify(
            () => mockAnalytics.sendBooruAddedEvent(
              url: captureAny(named: 'url'),
              hintSite: captureAny(named: 'hintSite'),
              totalSites: captureAny(named: 'totalSites'),
              hasLogin: false,
            ),
          ).called(1);
        },
      );
    },
  );

  group(
    'Update a config',
    () {
      //TODO: Add tests
    },
  );
}
