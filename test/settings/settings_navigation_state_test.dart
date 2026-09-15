// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/settings/src/providers/settings_navigation_provider.dart';
import 'package:boorusama/core/settings/src/types/settings_navigation_state.dart';

void main() {
  group('SettingsDestinationCatalog', () {
    final catalog = SettingsDestinationCatalog(
      categoryIds: const {'appearance', 'privacy'},
      parentById: const {'app_lock': 'privacy'},
    );

    test('resolves compact, wide, and nested initial destinations', () {
      expect(
        resolveSettingsInitialPath(
          catalog: catalog,
          presentation: SettingsPresentation.compact,
        ),
        isEmpty,
      );
      expect(
        resolveSettingsInitialPath(
          catalog: catalog,
          presentation: SettingsPresentation.wide,
        ),
        ['appearance'],
      );
      expect(
        resolveSettingsInitialPath(
          catalog: catalog,
          presentation: SettingsPresentation.compact,
          initialDestination: 'app_lock',
        ),
        ['privacy', 'app_lock'],
      );
    });

    test('rejects unknown parents and cycles', () {
      expect(
        () => SettingsDestinationCatalog(
          categoryIds: const {'privacy'},
          parentById: const {'app_lock': 'missing'},
        ),
        throwsArgumentError,
      );
      expect(
        () => SettingsDestinationCatalog(
          parentById: const {'first': 'second', 'second': 'first'},
        ),
        throwsArgumentError,
      );
    });
  });

  group('SettingsNavigationState', () {
    test('defensively copies constructor and copyWith paths', () {
      final source = ['privacy'];
      final state = SettingsNavigationState(path: source);
      source.add('app_lock');

      expect(state.path, ['privacy']);
      expect(() => state.path.add('app_lock'), throwsUnsupportedError);

      final replacement = ['privacy', 'app_lock'];
      final copied = state.copyWith(path: replacement);
      replacement.clear();
      expect(copied.path, ['privacy', 'app_lock']);
    });

    test('seed defensively copies its initial path', () {
      final source = ['privacy'];
      final seed = SettingsNavigationSeed(
        hostIdentity: 'host',
        initialPath: source,
      );
      source.clear();

      expect(seed.initialPath, ['privacy']);
      expect(() => seed.initialPath.clear(), throwsUnsupportedError);
    });
  });

  group('settingsNavigationProvider', () {
    final catalog = SettingsDestinationCatalog(
      categoryIds: const {'appearance', 'privacy'},
      parentById: const {'app_lock': 'privacy'},
    );

    test(
      'initializes synchronously and supports category, nested, and back',
      () {
        final container = ProviderContainer(
          overrides: [
            settingsDestinationCatalogProvider.overrideWithValue(catalog),
          ],
        );
        addTearDown(container.dispose);
        final seed = SettingsNavigationSeed(
          hostIdentity: 'host',
          initialPath: const ['privacy'],
        );
        final subscription = container.listen(
          settingsNavigationProvider(seed),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);

        expect(container.read(settingsNavigationProvider(seed)).path, [
          'privacy',
        ]);
        final notifier = container.read(
          settingsNavigationProvider(seed).notifier,
        );
        notifier.openNested('app_lock');
        expect(container.read(settingsNavigationProvider(seed)).path, [
          'privacy',
          'app_lock',
        ]);
        notifier.back();
        expect(container.read(settingsNavigationProvider(seed)).path, [
          'privacy',
        ]);
        notifier.back();
        expect(container.read(settingsNavigationProvider(seed)).path, isEmpty);
        notifier.selectCategory('appearance');
        expect(container.read(settingsNavigationProvider(seed)).path, [
          'appearance',
        ]);
      },
    );

    test('reselecting a parent only leaves a nested destination', () {
      final container = ProviderContainer(
        overrides: [
          settingsDestinationCatalogProvider.overrideWithValue(catalog),
        ],
      );
      addTearDown(container.dispose);
      final seed = SettingsNavigationSeed(
        hostIdentity: 'host',
        initialPath: const ['privacy'],
      );
      final subscription = container.listen(
        settingsNavigationProvider(seed),
        (_, _) {},
      );
      addTearDown(subscription.close);
      final notifier = container.read(
        settingsNavigationProvider(seed).notifier,
      );

      notifier.selectCategory('privacy');
      final topLevelState = container.read(settingsNavigationProvider(seed));
      notifier.selectCategory('privacy');
      expect(
        container.read(settingsNavigationProvider(seed)),
        same(topLevelState),
      );
      notifier.openNested('app_lock');
      notifier.selectCategory('privacy');
      expect(container.read(settingsNavigationProvider(seed)).path, [
        'privacy',
      ]);
    });

    test(
      'host identities isolate state and invalidation restores the seed',
      () {
        final container = ProviderContainer(
          overrides: [
            settingsDestinationCatalogProvider.overrideWithValue(catalog),
          ],
        );
        addTearDown(container.dispose);
        final first = SettingsNavigationSeed(
          hostIdentity: 'first',
          initialPath: const ['privacy'],
        );
        final equalFirst = SettingsNavigationSeed(
          hostIdentity: 'first',
          initialPath: const ['privacy'],
        );
        final second = SettingsNavigationSeed(
          hostIdentity: 'second',
          initialPath: const ['privacy'],
        );
        final subscriptions = [
          container.listen(settingsNavigationProvider(first), (_, _) {}),
          container.listen(settingsNavigationProvider(second), (_, _) {}),
        ];
        addTearDown(() {
          for (final subscription in subscriptions) {
            subscription.close();
          }
        });

        container
            .read(settingsNavigationProvider(first).notifier)
            .openNested('app_lock');
        expect(container.read(settingsNavigationProvider(equalFirst)).path, [
          'privacy',
          'app_lock',
        ]);
        expect(container.read(settingsNavigationProvider(second)).path, [
          'privacy',
        ]);

        container.invalidate(settingsNavigationProvider(first));
        expect(container.read(settingsNavigationProvider(first)).path, [
          'privacy',
        ]);
      },
    );

    test('empty catalogs and unknown commands retain state', () {
      final container = ProviderContainer(
        overrides: [
          settingsDestinationCatalogProvider.overrideWithValue(
            SettingsDestinationCatalog(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final seed = SettingsNavigationSeed(hostIdentity: 'empty');
      final subscription = container.listen(
        settingsNavigationProvider(seed),
        (_, _) {},
      );
      addTearDown(subscription.close);
      final notifier = container.read(
        settingsNavigationProvider(seed).notifier,
      );

      notifier.selectCategory('missing');
      notifier.openNested('missing');
      notifier.back();
      expect(container.read(settingsNavigationProvider(seed)).path, isEmpty);
    });
  });
}
