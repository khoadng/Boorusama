// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:http/http.dart';
import 'package:yaml/yaml.dart';

// Project imports:
import '../../../foundation/loggers.dart';
import 'booru.dart';
import 'booru_factory.dart';

const String _assetUrl = 'boorus.yaml';

Future<List<Booru>> loadBoorus(dynamic yaml) async {
  final boorus = <Booru>[];

  for (final item in yaml) {
    final name = item.keys.first as String;
    final values = item[name];

    boorus.add(BooruFactory.parse(name, values));
  }

  return boorus;
}

Future<List<Booru>> loadBoorusFromAssets() async {
  final yaml = await rootBundle.loadString(_assetUrl);
  final data = loadYaml(yaml);

  return loadBoorus(data);
}

Future<List<Booru>> loadBoorusFromGithub(
  String githubLinkUrl,
  Logger logger,
) async {
  try {
    final uri = Uri.parse(githubLinkUrl);
    final response = await get(uri);

    if (response.statusCode == 200) {
      final data = loadYaml(response.body);

      logger.logI('BooruLoader', 'Booru definition loaded from Github');

      return loadBoorus(data);
    } else {
      logger.logE(
        'BooruLoader',
        'Failed to load boorus from Github with status code ${response.statusCode}, fallback to assets',
      );
      return loadBoorusFromAssets();
    }
  } catch (e) {
    logger.logE(
      'BooruLoader',
      'Failed to load boorus from Github with error $e, fallback to assets',
    );
    return loadBoorusFromAssets();
  }
}
