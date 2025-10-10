import 'package:codegen/codegen.dart';

class RegistryGenerator {
  String generate(List<Map<String, String>> configs) {
    final imports = configs.map((config) {
      final yamlName = config['yamlName']!;
      final fileName = yamlName.replaceAll('-', '_');
      return {
        'yamlName': yamlName,
        'fileName': fileName,
        'dartName': config['dartName']!,
      };
    }).toList();

    final mapEntries = configs.map((config) {
      final dartName = config['dartName']!;
      return {
        'dartName': dartName,
        'functionName': 'create${_capitalize(dartName)}',
      };
    }).toList();

    final context = {
      'imports': imports,
      'mapEntries': mapEntries,
    };

    final template = TemplateManager().loadTemplate('registry.mustache');
    return TemplateManager().render(template, context);
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}
