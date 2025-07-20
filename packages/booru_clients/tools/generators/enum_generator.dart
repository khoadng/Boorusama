import 'generator.dart';

class EnumGenerator extends TemplateGenerator<List<String>> {
  @override
  String get templateName => 'enum.mustache';

  @override
  Map<String, dynamic> buildContext(List<String> featureIds) {
    return {
      'featureIds': featureIds
          .asMap()
          .entries
          .map(
            (entry) => {
              'name': entry.value,
              'isLast': entry.key == featureIds.length - 1,
            },
          )
          .toList(),
    };
  }
}
