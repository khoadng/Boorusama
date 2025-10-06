import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/noop_rule.dart';

final plugin = BoorusamaLintPlugin();

class BoorusamaLintPlugin extends Plugin {
  @override
  String get name => 'boorusama_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(NoopRule());
  }
}
