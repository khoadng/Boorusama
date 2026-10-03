// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/settings_navigation_state.dart';

final settingsDestinationCatalogProvider = Provider<SettingsDestinationCatalog>(
  (ref) => SettingsDestinationCatalog(),
);

final settingsNavigationProvider = NotifierProvider.autoDispose
    .family<
      SettingsNavigationNotifier,
      SettingsNavigationState,
      SettingsNavigationSeed
    >(
      SettingsNavigationNotifier.new,
      dependencies: [settingsDestinationCatalogProvider],
    );

class SettingsNavigationNotifier
    extends
        AutoDisposeFamilyNotifier<
          SettingsNavigationState,
          SettingsNavigationSeed
        > {
  @override
  SettingsNavigationState build(SettingsNavigationSeed seed) =>
      SettingsNavigationState(path: seed.initialPath);

  bool open(String destinationId) {
    final catalog = ref.read(settingsDestinationCatalogProvider);
    final path = catalog.pathFor(destinationId);
    if (path == null) return false;

    final next = SettingsNavigationState(path: path);
    if (next == state) return false;

    state = next;
    return true;
  }

  void back() {
    if (state.path.isEmpty) return;
    state = SettingsNavigationState(
      path: state.path.take(state.path.length - 1),
    );
  }
}
