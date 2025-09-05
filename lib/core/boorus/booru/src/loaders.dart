// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:yaml/yaml.dart';

// Project imports:
import '../../engine/engine.dart';
import 'booru.dart';
import 'booru_db.dart';

const _assetUrl = 'boorus.yaml';

Future<BooruDb> loadBoorus(
  dynamic yaml,
  BooruRegistry registry,
) async {
  final boorus = <Booru>[];

  for (final item in yaml) {
    final name = item.keys.first as String;
    final values = item[name];

    final booru = registry.parseFromConfig(name, values);

    boorus.add(booru);
  }

  return BooruDb(boorus: boorus);
}

Future<BooruDb> loadBoorusFromAssets(BooruRegistry registry) async {
  final yaml = await rootBundle.loadString(_assetUrl);
  final data = loadYaml(yaml);

  return loadBoorus(data, registry);
}
