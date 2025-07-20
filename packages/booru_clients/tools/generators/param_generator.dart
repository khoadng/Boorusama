import '../utils/string_utils.dart';
import 'generator.dart';

class ParamGenerator extends TemplateGenerator<Set<String>> {
  @override
  String get templateName => 'params.mustache';

  @override
  Map<String, dynamic> buildContext(Set<String> params) {
    final sortedParams = params.toList()..sort();

    return {
      'params': sortedParams
          .map(
            (param) => {
              'kebabName': param,
              'camelName': kebabToCamel(param),
            },
          )
          .toList(),
    };
  }
}
