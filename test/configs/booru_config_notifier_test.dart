// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/analytics.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/current.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/core/configs/src/booru_config_converter.dart';
import 'package:boorusama/core/foundation/loggers.dart';
import 'package:boorusama/core/settings/src/data/providers.dart';
import 'package:boorusama/core/settings/src/providers/settings_notifier.dart';
import 'package:boorusama/core/settings/src/providers/settings_provider.dart';
import 'package:boorusama/core/settings/src/types/settings.dart';
import 'package:boorusama/core/settings/src/types/settings_repository.dart';
import '../riverpod_test_utils.dart';

class InMemoryBooruConfigRepository implements BooruConfigRepository {
  final List<BooruConfig> _configs = [];

  @override
  Future<BooruConfig?> add(BooruConfigData booruConfigData) {
    final id = _configs.isEmpty ? 1 : _configs.last.id + 1;
    final config = booruConfigData.toBooruConfig(id: id);

    if (config == null) return Future.value();

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
        .nonNulls
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
    if (index == -1) return Future.value();

    final config = booruConfigData.toBooruConfig(id: id);
    if (config == null) return Future.value();

    _configs[index] = config;
    return Future.value(config);
  }
}

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository() : _settings = Settings.defaultSettings;

  late Settings _settings;

  @override
  Future<bool> save(Settings settings) {
    _settings = settings;
    return Future.value(true);
  }

  @override
  SettingsOrError load() => TaskEither.right(_settings);
}

class MockAnalytics extends Mock implements AnalyticsInterface {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockLogger extends Mock implements Logger {}

final mockAnalytics = MockAnalytics();

class MockCallback extends Mock {
  // ignore: unreachable_from_main
  void call();
}

ProviderContainer createBooruConfigContainer({
  required SettingsRepository settingsRepository,
  BooruConfigRepository? booruConfigRepository,
}) {
  final mockLogger = MockLogger();

  return createContainer(
    overrides: [
      booruConfigRepoProvider.overrideWith(
        (ref) => booruConfigRepository ?? InMemoryBooruConfigRepository(),
      ),
      settingsRepoProvider.overrideWithValue(settingsRepository),
      settingsNotifierProvider
          .overrideWith(() => SettingsNotifier(Settings.defaultSettings)),
      initialSettingsBooruConfigProvider.overrideWithValue(BooruConfig.empty),
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
      final configData2 = BooruConfig.empty.toBooruConfigData();

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

          final settings = container.read(settingsProvider);

          expect(
            settings.booruConfigIdOrders,
            '1',
          );
        },
      );

      // should update current booru config if set as current
      test(
        'should update current booru config if set as current',
        () async {
          await getNotifier().add(
            data: configData,
          );

          await getNotifier().add(
            data: configData2,
            setAsCurrent: true,
          );

          expect(
            container.read(currentBooruConfigProvider).id,
            2,
          );
        },
      );

      test(
        'should update current config if there is no current config',
        () async {
          await getNotifier().add(
            data: configData,
          );

          final currentConfig = container.read(currentBooruConfigProvider);

          expect(
            currentConfig.id,
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

  group(
    'Delete a config',
    () {
      group(
        'when there is only a single config',
        () {
          final config1 = BooruConfig.empty.toBooruConfigData();

          late ProviderContainer container;

          BooruConfigNotifier notifier() =>
              container.read(booruConfigProvider.notifier);

          setUp(
            () async {
              container = createBooruConfigContainer(
                settingsRepository: InMemorySettingsRepository(),
              );

              await notifier().add(data: config1);
            },
          );

          test(
            'should clear all configs',
            () async {
              await notifier().delete(config1.toBooruConfig(id: 1)!);

              final newConfigs = container.read(booruConfigProvider);

              expect(
                listEquals(
                  null,
                  newConfigs,
                ),
                isTrue,
              );
            },
          );

          test(
            'should clear the order',
            () async {
              await notifier().delete(config1.toBooruConfig(id: 1)!);

              final settings = container.read(settingsProvider);

              expect(
                settings.booruConfigIdOrders,
                '',
              );
            },
          );

          test(
            'should clear the current config',
            () async {
              await notifier().delete(config1.toBooruConfig(id: 1)!);

              final currentConfig = container.read(currentBooruConfigProvider);

              expect(
                currentConfig.id,
                BooruConfig.empty.id,
              );
            },
          );
        },
      );

      group(
        'from a list of 2 or more configs',
        () {
          final config1 = BooruConfig.empty.toBooruConfigData();
          final config2 = BooruConfig.empty.toBooruConfigData();
          final config3 = BooruConfig.empty.toBooruConfigData();

          late ProviderContainer container;

          BooruConfigNotifier notifier() =>
              container.read(booruConfigProvider.notifier);

          group(
            'when it is not the currently selected config',
            () {
              setUpAll(
                () async {
                  container = createBooruConfigContainer(
                    settingsRepository: InMemorySettingsRepository(),
                  );
                  await notifier().add(data: config1);
                  await notifier().add(
                    data: config2,
                    setAsCurrent: true,
                  );
                  await notifier().add(data: config3);

                  await notifier().delete(config1.toBooruConfig(id: 1)!);
                },
              );

              test(
                'should works',
                () async {
                  final newConfigs = container.read(booruConfigProvider);

                  expect(
                    listEquals(
                      [
                        config2.toBooruConfig(id: 2),
                        config3.toBooruConfig(id: 3),
                      ],
                      newConfigs,
                    ),
                    isTrue,
                  );
                },
              );

              test(
                'should update order',
                () async {
                  final settings = container.read(settingsProvider);

                  expect(
                    settings.booruConfigIdOrders,
                    '2 3',
                  );
                },
              );
            },
          );

          group(
            'when it is the currently selected config',
            () {
              setUpAll(
                () async {
                  container = createBooruConfigContainer(
                    settingsRepository: InMemorySettingsRepository(),
                  );
                  await notifier().add(data: config1);
                  await notifier().add(
                    data: config2,
                    setAsCurrent: true,
                  );
                  await notifier().add(data: config3);

                  await notifier().delete(config2.toBooruConfig(id: 2)!);
                },
              );

              test(
                'should works',
                () async {
                  final newConfigs = container.read(booruConfigProvider);

                  expect(
                    listEquals(
                      [
                        config1.toBooruConfig(id: 1),
                        config3.toBooruConfig(id: 3),
                      ],
                      newConfigs,
                    ),
                    isTrue,
                  );
                },
              );

              test(
                'should update order',
                () async {
                  final settings = container.read(settingsProvider);

                  expect(
                    settings.booruConfigIdOrders,
                    '1 3',
                  );
                },
              );

              test(
                'should update current config to the first config',
                () async {
                  final currentConfig =
                      container.read(currentBooruConfigProvider);

                  expect(
                    currentConfig.id,
                    1,
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}
