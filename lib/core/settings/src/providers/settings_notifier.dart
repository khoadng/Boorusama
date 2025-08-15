// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/loggers/providers.dart';
import '../../../analytics/providers.dart';
import '../../../analytics/types.dart';
import '../data/providers.dart';
import '../types/settings.dart';

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, Settings>(
  () => throw UnimplementedError(),
  name: 'settingsNotifierProvider',
);

final initialSettingsProvider = Provider<Settings>(
  (ref) => throw UnimplementedError(),
  name: 'initialSettingsProvider',
);

class SettingsNotifier extends Notifier<Settings> {
  SettingsNotifier(this.initialSettings);

  final Settings initialSettings;

  @override
  Settings build() {
    return initialSettings;
  }

  Future<void> updateWith(
    Settings Function(Settings) selector,
  ) async {
    final currentSettings = state;
    final newSettings = selector(currentSettings);

    return updateSettings(newSettings);
  }

  Future<void> updateSettings(Settings settings) async {
    final currentSettings = state;
    final success = await ref.read(settingsRepoProvider).save(settings);

    if (success) {
      for (var i = 0; i < currentSettings.props.length; i++) {
        final cs = currentSettings.props[i];
        final ns = settings.props[i];

        if (cs != ns) {
          ref
              .read(loggerProvider)
              .verbose(
                'Settings',
                'Settings updated: ${cs.runtimeType} $cs -> $ns',
              );
        }
      }
      state = settings;

      ref
          .read(analyticsProvider)
          .whenData(
            (a) => a?.logSettingsChangedEvent(
              oldValue: currentSettings,
              newValue: settings,
            ),
          );
    }
  }
}
