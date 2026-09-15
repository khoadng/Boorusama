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

  void selectCategory(String categoryId) {
    final catalog = ref.read(settingsDestinationCatalogProvider);
    if (!catalog.isCategory(categoryId)) return;

    final current = state.selectedCategoryId;
    if (current == categoryId && state.path.length == 1) return;

    state = SettingsNavigationState(path: [categoryId]);
  }

  void openNested(String destinationId) {
    final catalog = ref.read(settingsDestinationCatalogProvider);
    final path = catalog.pathFor(destinationId);
    if (path == null || path.length < 2) return;

    state = SettingsNavigationState(path: path);
  }

  void back() {
    if (!state.canGoBack) return;
    state = SettingsNavigationState(
      path: state.path.take(state.path.length - 1),
    );
  }
}
