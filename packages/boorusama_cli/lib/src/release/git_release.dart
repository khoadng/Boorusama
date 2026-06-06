import '../io/process_runner.dart';
import '../tool/tool_runner.dart';

final class GitRelease {
  const GitRelease(this.tools);

  final ToolRunner tools;

  Future<void> requireCleanTree({required bool allowDirty}) async {
    if (allowDirty) return;
    if (!await isWorkingTreeClean()) {
      throw const ProcessFailure(
        'Working tree is not clean. Commit or stash changes, or pass --allow-dirty.',
      );
    }
  }

  Future<bool> isWorkingTreeClean() async {
    final status = await tools.gitOutput(['status', '--porcelain']);
    return status.trim().isEmpty;
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

  Future<void> checkoutBranch(String branch) {
    return tools.git(['checkout', branch]);
  }

  Future<void> createBranch(String branch) {
    return tools.git(['checkout', '-b', branch]);
  }

  Future<void> checkoutRemoteBranch(String branch) {
    return tools.git(['checkout', '-b', branch, '--track', 'origin/$branch']);
  }

  Future<void> pushTag(String tag) {
    return tools.git(['push', 'origin', tag]);
  }

  Future<bool> localBranchExists(String branch) async {
    final output = await tools.gitOutput(['branch', '--list', branch]);
    return output.trim().split('\n').any((line) {
      return line.replaceFirst('*', '').trim() == branch;
    });
  }

  Future<bool> remoteBranchExists(String branch) async {
    final output = await tools.gitOutput([
      'ls-remote',
      '--heads',
      'origin',
      branch,
    ]);
    return output.trim().isNotEmpty && output != 'unknown';
  }

  Future<bool> localTagExists(String tag) async {
    final output = await tools.gitOutput(['tag', '--list', tag]);
    return output.trim() == tag;
  }

  Future<bool> remoteTagExists(String tag) async {
    final output = await tools.gitOutput([
      'ls-remote',
      '--tags',
      'origin',
      tag,
    ]);
    return output.trim().isNotEmpty && output != 'unknown';
  }

  Future<void> requireLocalHeadMatchesTag(String tag) async {
    final head = await tools.gitOutput(['rev-parse', 'HEAD']);
    final tagCommit = await tools.gitOutput(['rev-list', '-n', '1', tag]);

    if (head == 'unknown' || tagCommit == 'unknown' || head != tagCommit) {
      throw ProcessFailure(
        'Current HEAD does not match $tag. Check out the tagged release commit before running this command.',
      );
    }
  }

  Future<void> requireRemoteTag(String tag) async {
    final remote = await tools.gitOutput([
      'ls-remote',
      '--tags',
      'origin',
      tag,
    ]);

    if (remote.trim().isEmpty || remote == 'unknown') {
      throw ProcessFailure(
        'Git tag does not exist on origin: $tag. Run the Play release or push the tag first.',
      );
    }
  }
}
