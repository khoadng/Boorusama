import '../tool/tool_runner.dart';

final class GitInfo {
  const GitInfo({required this.commit, required this.branch});

  final String commit;
  final String branch;

  static Future<GitInfo> read(ToolRunner tools) async {
    final commit = await tools.gitOutput(['rev-parse', 'HEAD']);
    final branch = await tools.gitOutput(['rev-parse', '--abbrev-ref', 'HEAD']);
    return GitInfo(commit: commit, branch: branch);
  }
}
