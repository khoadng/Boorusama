import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'catalog.dart';
import 'emitter.dart';

final class SettingsGeneration {
  static const outputDirectory = 'lib/core/settings/src/generated';

  Future<Map<String, String>> generate(Directory root) async {
    final input = File('${root.path}/settings.yaml');
    final translations =
        jsonDecode(
              await File(
                '${root.path}/packages/i18n/translations/en-US.json',
              ).readAsString(),
            )
            as Map<String, dynamic>;
    final catalog = SettingsCatalog.parse(
      await input.readAsString(),
      translations: translations,
      icons: await readIcons(root),
      boorus: {
        for (final entry
            in loadYaml(
                  await File(
                    '${root.path}/packages/booru_clients/boorus.yaml',
                  ).readAsString(),
                )
                as List)
          for (final booru in (entry as Map).entries)
            booru.key as String:
                ((booru.value as Map)['metadata'] as Map)['id'] as int,
      },
      path: input.path,
    );
    return SettingsEmitter(catalog).emit();
  }

  Future<List<String>> run(
    Directory root, {
    bool check = false,
    bool dryRun = false,
  }) async {
    final outputs = await generate(root);
    final changed = <String>[];
    for (final output in outputs.entries) {
      final relative = '$outputDirectory/${output.key}';
      final file = File('${root.path}/$relative');
      if (!file.existsSync() || await file.readAsString() != output.value) {
        changed.add(relative);
      }
    }
    if (check && changed.isNotEmpty) {
      throw StateError(
        'Settings bindings are stale: ${changed.join(', ')}. Run boorusama settings gen.',
      );
    }
    if (!check && !dryRun) {
      for (final relative in changed) {
        final file = File('${root.path}/$relative');
        await file.parent.create(recursive: true);
        final temporary = File('${file.path}.tmp');
        await temporary.writeAsString(outputs[file.uri.pathSegments.last]!);
        await temporary.rename(file.path);
      }
    }
    return changed;
  }

  static Future<Map<String, Set<String>>> readIcons(Directory root) async {
    final config = File('${root.path}/.dart_tool/package_config.json');
    if (!config.existsSync()) {
      throw StateError('Resolve app dependencies before generating settings.');
    }
    final packages =
        (jsonDecode(await config.readAsString()) as Map)['packages'] as List;
    final result = <String, Set<String>>{};
    for (final (family, package, source) in [
      (
        'FontAwesomeIcons',
        'font_awesome_flutter',
        'lib/font_awesome_flutter.dart',
      ),
      ('Symbols', 'material_symbols_icons', 'lib/symbols.dart'),
    ]) {
      final entries = packages.cast<Map>().where(
        (entry) => entry['name'] == package,
      );
      if (entries.length != 1) {
        throw StateError('Expected installed package $package');
      }
      final packageUri = config.uri.resolve(
        entries.single['rootUri'] as String,
      );
      final base = packageUri.path.endsWith('/')
          ? packageUri
          : Uri.parse('$packageUri/');
      final text = await File.fromUri(base.resolve(source)).readAsString();
      result[family] = RegExp(
        r'static\s+const\s+(?:FaIconData|IconData)\s+(\w+)\s*=',
      ).allMatches(text).map((m) => m[1]!).toSet();
      if (result[family]!.isEmpty) {
        throw StateError('No icon declarations found in $package/$source');
      }
    }
    return result;
  }
}
