import 'dart:io';

import 'package:codegen/codegen.dart';
import 'package:yaml/yaml.dart';
import 'parsers/data_extractor.dart';
import 'generators/config_generator.dart';

void main() async {
  try {
    await CodegenRunner().runWithInput(
      config: CodegenConfig(
        templateDirectory: 'tools/templates',
        inputPath: '../../boorus.yaml',
        outputPath: 'lib/src/generated/booru_config.dart',
      ),
      inputLoader: _loadYamlData,
      generator: _generateConfig,
    );
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Future<Map<String, dynamic>> _loadYamlData(String data) async {
  final yamlData = loadYaml(data);
  final gelbooruV2Config = DataExtractor.extractGelbooruV2Config(yamlData);

  if (gelbooruV2Config == null) {
    throw Exception('Failed to extract config from YAML data');
  }

  final allParams = DataExtractor.extractAllParams(yamlData);

  return {
    'gelbooruV2Config': gelbooruV2Config,
    'allParams': allParams,
    'yamlData': yamlData,
  };
}

Future<String> _generateConfig(Map<String, dynamic> data) async {
  return ConfigGenerator().generate(
    data['gelbooruV2Config'],
    data['allParams'],
    data['yamlData'],
  );
}
