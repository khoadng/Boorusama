import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _LocalLinter();

class _LocalLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [Noop(configs)];
}

class Noop extends DartLintRule {
  const Noop(this.configs) : super(code: _code);

  final CustomLintConfigs configs;

  static const _code = LintCode(
    name: 'foobar',
    problemMessage: 'This is a noop lint rule that does nothing.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    return;
  }
}
