// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../booru/booru.dart';
import 'booru_builder.dart';
import 'booru_engine.dart';

class BooruComponents {
  const BooruComponents({
    required this.parser,
    required this.createBuilder,
    required this.createRepository,
  });

  final BooruParser parser;
  final BooruBuilder Function() createBuilder;
  final BooruRepository Function(Ref ref) createRepository;
}

class BooruRegistry {
  final Map<BooruType, BooruComponents> _components = {};

  void register(BooruType booruType, BooruComponents components) {
    _components[booruType] = components;
  }

  BooruParser? getParser(BooruType booruType) {
    return _components[booruType]?.parser;
  }

  BooruEngine createEngine(Booru booru, Ref ref) {
    final type = booru.type;
    final components = _components[type];

    if (components == null) {
      throw Exception('No components registered for booru type: ${booru.type}');
    }

    return BooruEngine(
      booru: booru,
      builder: components.createBuilder(),
      repository: components.createRepository(ref),
    );
  }

  Booru parseFromConfig(String name, dynamic data) {
    final type = BooruType.fromYamlName(name);
    if (type == BooruType.unknown) {
      throw Exception('Unknown booru: $name');
    }

    final components = _components[type];
    if (components == null) {
      throw Exception('No components registered for booru type: $type');
    }

    return components.parser.parse(name, data);
  }
}
