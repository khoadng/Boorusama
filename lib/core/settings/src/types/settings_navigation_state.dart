// Dart imports:
import 'dart:collection';

// Package imports:
import 'package:equatable/equatable.dart';

const double kSettingsWideBreakpoint = 700;

enum SettingsPresentation {
  compact,
  wide;

  factory SettingsPresentation.fromWidth(double width) =>
      width >= kSettingsWideBreakpoint ? wide : compact;
}

class SettingsNavigationState extends Equatable {
  SettingsNavigationState({
    Iterable<String> path = const [],
  }) : path = List.unmodifiable(path);

  final List<String> path;

  String? get selectedCategoryId => path.firstOrNull;

  String? get currentDestinationId => path.lastOrNull;

  // The wide layout always shows a destination, so an empty path stands for
  // the default category there.
  List<String> visiblePath({
    required SettingsPresentation presentation,
    required SettingsDestinationCatalog catalog,
  }) => switch (presentation) {
    SettingsPresentation.wide when path.isEmpty => [
      ?catalog.defaultCategoryId,
    ],
    _ => path,
  };

  bool canGoBack(SettingsPresentation presentation) => switch (presentation) {
    SettingsPresentation.compact => path.isNotEmpty,
    SettingsPresentation.wide => path.length > 1,
  };

  SettingsNavigationState copyWith({
    Iterable<String>? path,
  }) => SettingsNavigationState(path: path ?? this.path);

  @override
  List<Object?> get props => [path];
}

class SettingsNavigationSeed extends Equatable {
  SettingsNavigationSeed({
    required this.hostIdentity,
    Iterable<String> initialPath = const [],
  }) : initialPath = List.unmodifiable(initialPath);

  final Object hostIdentity;
  final List<String> initialPath;

  @override
  List<Object?> get props => [hostIdentity, initialPath];
}

class SettingsDestinationCatalog {
  SettingsDestinationCatalog({
    Iterable<String> categoryIds = const [],
    Map<String, String> parentById = const {},
  }) : categoryIds = UnmodifiableSetView(Set.of(categoryIds)),
       parentById = Map.unmodifiable(parentById) {
    _validate();
  }

  final Set<String> categoryIds;
  final Map<String, String> parentById;

  Set<String> get destinationIds => {
    ...categoryIds,
    ...parentById.keys,
  };

  String? get defaultCategoryId => categoryIds.firstOrNull;

  bool isCategory(String id) => categoryIds.contains(id);

  bool isDestination(String id) => destinationIds.contains(id);

  List<String>? pathFor(String id) {
    if (!isDestination(id)) return null;

    final path = <String>[id];
    var current = id;
    var parent = parentById[current];
    while (parent != null) {
      path.insert(0, parent);
      current = parent;
      parent = parentById[current];
    }
    return List.unmodifiable(path);
  }

  List<String> resolveInitialPath(String? id) => switch (id) {
    final id? => pathFor(id) ?? const [],
    null => const [],
  };

  void _validate() {
    final ids = destinationIds;
    for (final entry in parentById.entries) {
      if (!ids.contains(entry.value)) {
        throw ArgumentError.value(
          entry.value,
          'parentById[${entry.key}]',
          'Parent is not a known destination',
        );
      }

      final seen = <String>{entry.key};
      var current = entry.key;
      var parent = parentById[current];
      while (parent != null) {
        if (!seen.add(parent)) {
          throw ArgumentError.value(
            parentById,
            'parentById',
            'Destination ancestry contains a cycle',
          );
        }
        current = parent;
        parent = parentById[current];
      }
    }
  }
}
