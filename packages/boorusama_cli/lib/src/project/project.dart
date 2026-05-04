import 'dart:io';

import 'package:yaml/yaml.dart';

import '../tool/tool_runner.dart';
import 'env.dart';
import 'git.dart';
import 'pubspec.dart';

final class Project {
  const Project({
    required this.root,
    required this.pubspec,
    required this.env,
    required this.git,
  });

  final Directory root;
  final PubspecInfo pubspec;
  final Env env;
  final GitInfo git;

  static Directory findRoot() {
    final explicitRoot = Platform.environment['BOORUSAMA_ROOT'];
    if (explicitRoot != null && explicitRoot.isNotEmpty) {
      final root = Directory(explicitRoot).absolute;
      if (_isBoorusamaRoot(root)) return root;
      throw StateError(
        'BOORUSAMA_ROOT does not point to the Boorusama app root: ${root.path}',
      );
    }

    return _findRoot(Directory.current);
  }

  static Env loadEnv(Directory root) => Env.load(File('${root.path}/.env'));

  static Future<Project> load({
    required Directory root,
    required Env env,
    required ToolRunner tools,
  }) async {
    final pubspec = PubspecInfo.read(File('${root.path}/pubspec.yaml'));
    final git = await GitInfo.read(tools);
    return Project(root: root, pubspec: pubspec, env: env, git: git);
  }

  static Directory _findRoot(Directory start) {
    var current = start.absolute;
    while (true) {
      if (_isBoorusamaRoot(current)) return current;

      final parent = current.parent;
      if (parent.path == current.path) {
        throw StateError(
          'Could not find Boorusama app root. Set BOORUSAMA_ROOT if running the CLI outside the repository.',
        );
      }
      current = parent;
    }
  }

  static bool _isBoorusamaRoot(Directory directory) {
    final pubspec = File('${directory.path}/pubspec.yaml');
    if (!pubspec.existsSync()) return false;

    final yaml = loadYaml(pubspec.readAsStringSync());
    if (yaml is! YamlMap || yaml['name'] != 'boorusama') return false;

    return Directory('${directory.path}/lib').existsSync() &&
        Directory('${directory.path}/android').existsSync();
  }
}
