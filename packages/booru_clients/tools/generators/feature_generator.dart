import 'package:codegen/codegen.dart';
import '../models/booru_config.dart';

class FeatureGenerator extends TemplateGenerator<BooruConfig> {
  @override
  String get templateName => 'features.mustache';

  @override
  Map<String, dynamic> buildContext(BooruConfig config) {
    return _buildContextWithOverrides(config, '', '');
  }

  String generateWithOverrides(
    BooruConfig config,
    String overrideClasses,
    String featureGetters,
  ) {
    final template = TemplateManager().loadTemplate(templateName);
    final context = _buildContextWithOverrides(
      config,
      overrideClasses,
      featureGetters,
    );
    return TemplateManager().render(template, context);
  }

  Map<String, dynamic> _buildContextWithOverrides(
    BooruConfig config,
    String overrideClasses,
    String featureGetters,
  ) {
    final featureClasses = config.features.entries.map((entry) {
      final featureId = entry.key;
      final feature = entry.value;
      final capabilities = feature.capabilities ?? [];

      return {
        'className': '${featureId.capitalize()}Feature',
        'featureId': featureId,
        'endpointType': feature.type,
        'hasCapabilities': capabilities.isNotEmpty,
        'capabilities': capabilities
            .map(
              (cap) => {
                'name': kebabToCamel(cap.name),
                'type': cap.type,
                'isLast': cap == capabilities.last,
              },
            )
            .toList(),
      };
    }).toList();

    return {
      'featureClasses': featureClasses,
      'overrideClasses': overrideClasses,
      'featureGetters': featureGetters,
    };
  }

  String buildFeatureConstructor(
    String featureId,
    List<CapabilityField>? capabilities,
    Map<String, ActionConfig> actions, {
    int indentLevel = 4,
  }) {
    final baseIndent = ' ' * indentLevel;
    final paramIndent = ' ' * (indentLevel + 2);
    final params = <String>[];

    for (final capability in capabilities ?? const <CapabilityField>[]) {
      params.add(
        '$paramIndent${kebabToCamel(capability.name)}: ${_formatDartValue(capability.value)},',
      );
    }
    if (actions.isNotEmpty) {
      params.add(
        '$paramIndent${'actions'}: ${_buildActionMap(actions, indentLevel)},',
      );
    }

    if (params.isEmpty) return '${featureId.capitalize()}Feature()';

    return '''${featureId.capitalize()}Feature(
${params.join('\n')}
$baseIndent)''';
  }

  String _buildActionMap(Map<String, ActionConfig> actions, int indentLevel) {
    final entryIndent = ' ' * (indentLevel + 4);
    final argumentIndent = ' ' * (indentLevel + 6);
    final closingIndent = ' ' * (indentLevel + 2);
    final entries = actions.entries
        .map((entry) {
          final action = entry.value;
          final baseUrl = action.baseUrl == null
              ? ''
              : '\n$argumentIndent baseUrl: ${_quote(action.baseUrl!)},';

          return '''$entryIndent${_quote(entry.key)}: FeatureActionEndpoint(
$argumentIndent name: ${_quote(action.name)},
$argumentIndent method: ActionRequestMethod.${_enumName(action.method)},
$argumentIndent path: ${_quote(action.endpoint)},$baseUrl
$argumentIndent auth: ActionAuthMode.${_enumName(action.auth)},
$argumentIndent responseType: ActionResponseType.${_enumName(action.response)},
$argumentIndent fixedParams: ${_formatStringMap(action.fixedParams)},
$argumentIndent paramMappings: ${_formatParamMappings(action.userParams)},
$entryIndent),''';
        })
        .join('\n');

    return '''{
$entries
$closingIndent}''';
  }

  String _formatStringMap(Map<String, String> values) {
    if (values.isEmpty) return '{}';
    return '{${values.entries.map((e) => '${_quote(e.key)}: ${_quote(e.value)}').join(', ')}}';
  }

  String _formatParamMappings(Map<String, String> values) {
    if (values.isEmpty) return '{}';
    return '{${values.entries.map((e) => 'P.${kebabToCamel(e.key)}: ${_quote(e.value)}').join(', ')}}';
  }

  String _enumName(String value) => switch (value) {
    'session-cookie' => 'sessionCookie',
    _ => value,
  };

  String _quote(String value) =>
      "'${value.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$')}'";

  String _formatDartValue(dynamic value) {
    return switch (value.runtimeType) {
      const (bool) || const (int) || const (double) => value.toString(),
      const (String) => _quote(value),
      _ => _quote(value.toString()),
    };
  }
}
