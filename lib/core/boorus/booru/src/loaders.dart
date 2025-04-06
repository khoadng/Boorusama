// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:yaml/yaml.dart';

// Project imports:
import 'booru.dart';
import 'booru_db.dart';
import 'parser.dart';

const String _assetUrl = 'boorus.yaml';

Future<BooruDb> loadBoorus(
  dynamic yaml,
  BooruParserRegistry registry,
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

Future<BooruDb> loadBoorusFromAssets(BooruParserRegistry registry) async {
  final yaml = await rootBundle.loadString(_assetUrl);
  final data = loadYaml(yaml);

  return loadBoorus(data, registry);
}
