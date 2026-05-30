import '../io/process_runner.dart';
import '../tool/tool_runner.dart';

final class GitRelease {
  const GitRelease(this.tools);

  final ToolRunner tools;

  Future<void> requireCleanTree({required bool allowDirty}) async {
    if (allowDirty) return;
    final status = await tools.gitOutput(['status', '--porcelain']);
    if (status.trim().isNotEmpty) {
      throw const ProcessFailure(
        'Working tree is not clean. Commit or stash changes, or pass --allow-dirty.',
      );
    }
  }

  Future<void> requireMissingTag(String tag) async {
    final local = await tools.gitOutput(['tag', '--list', tag]);
    if (local.trim() == tag) {
      throw ProcessFailure('Git tag already exists locally: $tag');
    }

    final remote = await tools.gitOutput([
      'ls-remote',
      '--tags',
      'origin',
      tag,
    ]);
    if (remote.trim().isNotEmpty && remote != 'unknown') {
      throw ProcessFailure('Git tag already exists on origin: $tag');
    }
  }

  Future<void> createTag(String tag, String message) {
    return tools.git(['tag', '-a', tag, '-m', message]);
  }

  Future<void> pushTag(String tag) {
    return tools.git(['push', 'origin', tag]);
  }
}
