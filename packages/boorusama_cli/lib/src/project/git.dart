import 'dart:io';

import '../tool/tool_runner.dart';

final class GitInfo {
  const GitInfo({required this.commit, required this.branch});

  final String commit;
  final String branch;

  static Future<GitInfo> read(
    ToolRunner tools, {
    Map<String, String>? environment,
  }) async {
    final env = environment ?? Platform.environment;
    final commit =
        _override(env, 'BOORUSAMA_GIT_COMMIT') ??
        await tools.gitOutput(['rev-parse', 'HEAD']);
    final branch =
        _override(env, 'BOORUSAMA_GIT_BRANCH') ??
        await tools.gitOutput(['rev-parse', '--abbrev-ref', 'HEAD']);
    return GitInfo(commit: commit, branch: branch);
  }

  static String? _override(Map<String, String> environment, String key) {
    final value = environment[key]?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}
