import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final class I18nCliConfig {
  const I18nCliConfig({
    required this.i18nDirectory,
    required this.translationsDirectory,
    required this.baseLocale,
    required this.indent,
    required this.preserveFormat,
    required this.sortKeys,
    required this.newlineAtEof,
    required this.untranslatedStrategy,
  });

  factory I18nCliConfig.load({
    required String workingDirectory,
    String? i18nDirectory,
  }) {
    final resolvedI18nDirectory = _resolveI18nDirectory(
      workingDirectory: workingDirectory,
      i18nDirectory: i18nDirectory,
    );
    final toolConfig = File(p.join(resolvedI18nDirectory, 'i18n_tool.yaml'));
    final slangConfig = File(p.join(resolvedI18nDirectory, 'slang.yaml'));

    final values = <String, Object?>{};

    if (slangConfig.existsSync()) {
      final yaml = loadYaml(slangConfig.readAsStringSync());
      if (yaml is YamlMap) {
        values['base_locale'] = yaml['base_locale'];
        values['translations_dir'] = yaml['input_directory'];
      }
    }

    if (toolConfig.existsSync()) {
      final yaml = loadYaml(toolConfig.readAsStringSync());
      if (yaml is YamlMap) {
        for (final entry in yaml.entries) {
          values[entry.key.toString()] = entry.value;
        }
      }
    }

    final translationsDirName =
        values['translations_dir']?.toString() ?? 'translations';

    return I18nCliConfig(
      i18nDirectory: resolvedI18nDirectory,
      translationsDirectory: p.normalize(
        p.join(resolvedI18nDirectory, translationsDirName),
      ),
      baseLocale: values['base_locale']?.toString() ?? 'en-US',
      indent: _readInt(values['indent']) ?? 2,
      preserveFormat: _readBool(values['preserve_format']) ?? true,
      sortKeys: _readBool(values['sort_keys']) ?? false,
      newlineAtEof: _readBool(values['newline_at_eof']) ?? true,
      untranslatedStrategy:
          values['untranslated_strategy']?.toString() ?? 'leave_missing',
    );
  }

  final String i18nDirectory;
  final String translationsDirectory;
  final String baseLocale;
  final int indent;
  final bool preserveFormat;
  final bool sortKeys;
  final bool newlineAtEof;
  final String untranslatedStrategy;

  static String _resolveI18nDirectory({
    required String workingDirectory,
    required String? i18nDirectory,
  }) {
    if (i18nDirectory != null) {
      return p.normalize(p.absolute(workingDirectory, i18nDirectory));
    }

    final directTranslations = Directory(
      p.join(workingDirectory, 'translations'),
    );
    final directSlang = File(p.join(workingDirectory, 'slang.yaml'));

    if (directTranslations.existsSync() && directSlang.existsSync()) {
      return p.normalize(p.absolute(workingDirectory));
    }

    final packageI18n = Directory(p.join(workingDirectory, 'packages', 'i18n'));
    if (packageI18n.existsSync()) {
      return p.normalize(p.absolute(packageI18n.path));
    }

    return p.normalize(p.absolute(workingDirectory));
  }

  static bool? _readBool(Object? value) {
    if (value is bool) return value;
    if (value == null) return null;

    return switch (value.toString()) {
      'true' => true,
      'false' => false,
      _ => null,
    };
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value == null) return null;

    return int.tryParse(value.toString());
  }
}
