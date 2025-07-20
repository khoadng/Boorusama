import 'dart:io';
import 'package:yaml/yaml.dart';
import 'parsers/data_extractor.dart';
import 'generators/config_generator.dart';

void main() async {
  final yamlFile = File('../../boorus.yaml');
  if (!yamlFile.existsSync()) {
    print('boorus.yaml not found');
    return;
  }

  final yamlContent = await yamlFile.readAsString();
  final yamlData = loadYaml(yamlContent) as YamlList;

  final gelbooruV2Config = DataExtractor.extractGelbooruV2Config(yamlData);
  if (gelbooruV2Config == null) {
    print('gelbooru_v2 config not found');
    return;
  }

  final allParams = DataExtractor.extractAllParams(yamlData);

  final generator = ConfigGenerator();
  final generated = generator.generate(gelbooruV2Config, allParams);

  final outputFile = File('lib/src/generated/booru_config.dart');
  await outputFile.create(recursive: true);
  await outputFile.writeAsString(generated);

  print('Generated booru_config.dart');
}
