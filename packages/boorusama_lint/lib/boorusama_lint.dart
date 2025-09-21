import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/lints/no_relative_src_imports.dart';

PluginBase createPlugin() => _LocalLinter();

class _LocalLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    NoRelativeSrcImports(configs),
  ];
}
