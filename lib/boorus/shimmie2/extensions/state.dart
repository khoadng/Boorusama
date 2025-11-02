// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'types.dart';

sealed class Shimmie2ExtensionsState extends Equatable {
  const Shimmie2ExtensionsState();

  bool hasExtension(KnownExtension extension);
  List<Extension> getByCategory(String category);
  Map<String, List<Extension>> getAllByCategory();
  List<String> getCategories();
}

class Shimmie2ExtensionsNotSupported extends Shimmie2ExtensionsState {
  const Shimmie2ExtensionsNotSupported();

  @override
  bool hasExtension(KnownExtension name) => false;

  @override
  List<Extension> getByCategory(String category) => [];

  @override
  Map<String, List<Extension>> getAllByCategory() => {};

  @override
  List<String> getCategories() => [];

  @override
  List<Object?> get props => [];
}

class Shimmie2ExtensionsData extends Shimmie2ExtensionsState {
  const Shimmie2ExtensionsData({
    required this.extensions,
  });

  factory Shimmie2ExtensionsData.empty() =>
      const Shimmie2ExtensionsData(extensions: []);

  final List<Extension> extensions;

  @override
  bool hasExtension(KnownExtension name) => extensions.any(
    (e) => e.name.toLowerCase() == name.extensionName.toLowerCase(),
  );

  @override
  List<Extension> getByCategory(String category) => extensions
      .where((e) => e.category.toLowerCase() == category.toLowerCase())
      .toList();

  @override
  Map<String, List<Extension>> getAllByCategory() {
    final grouped = <String, List<Extension>>{};
    for (final ext in extensions) {
      grouped.putIfAbsent(ext.category, () => []).add(ext);
    }
    return grouped;
  }

  @override
  List<String> getCategories() =>
      extensions.map((e) => e.category).toSet().toList();

  @override
  List<Object?> get props => [extensions];
}
