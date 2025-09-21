import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoRelativeSrcImports extends DartLintRule {
  const NoRelativeSrcImports(this.configs) : super(code: _code);

  final CustomLintConfigs configs;

  static const _code = LintCode(
    name: 'no_relative_src_imports',
    problemMessage:
        'Avoid relative imports that reference "/src/" directories. Import from barrel files instead.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final filePath = resolver.path;

    // Check if current file is in excluded paths
    if (_isFileExcluded(filePath)) {
      return;
    }

    context.registry.addImportDirective((node) {
      final uri = node.uri.stringValue;

      if (uri != null && _isRelativeImport(uri) && uri.contains('/src/')) {
        reporter.atNode(node, code);
      }
    });
  }

  bool _isRelativeImport(String uri) {
    return uri.startsWith('./') || uri.startsWith('../');
  }

  bool _isFileExcluded(String filePath) {
    final excludedPaths = _getExcludedPaths();

    for (final excludedPath in excludedPaths) {
      if (filePath.contains(excludedPath)) {
        return true;
      }
    }

    return false;
  }

  List<String> _getExcludedPaths() {
    // Get configuration from analysis_options.yaml
    final ruleConfig = configs.rules['no_relative_src_imports'];

    if (ruleConfig case Map<String, Object?> config) {
      final excluded = config['excluded_paths'];
      if (excluded is List) {
        return excluded.whereType<String>().toList();
      }
    }

    return [];
  }
}
