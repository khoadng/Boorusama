import '../../io/process_runner.dart';
import '../../tool/tool_runner.dart';
import 'tag_publish.dart';

final class GitRelease implements ReleaseTagRepository {
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

  Future<void> deleteLocalTag(String tag) {
    return tools.git(['tag', '-d', tag]);
  }

  Future<void> stageFiles(List<String> paths) {
    return tools.git(['add', ...paths]);
  }

  Future<bool> hasStagedChanges() async {
    final output = await tools.gitOutput(['diff', '--cached', '--name-only']);
    return output.trim().isNotEmpty && output != 'unknown';
  }

  Future<void> commit(String message) {
    return tools.git(['commit', '-m', message]);
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

  @override
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

  @override
  Future<String?> currentHead() async {
    final output = await tools.gitOutput(['rev-parse', 'HEAD']);
    if (output == 'unknown' || output.isEmpty) return null;
    return output;
  }

  @override
  Future<String?> localTagCommit(String tag) async {
    final output = await tools.gitOutput(['rev-list', '-n', '1', tag]);
    if (output == 'unknown' || output.isEmpty) return null;
    return output;
  }

  @override
  Future<String?> remoteTagCommit(String tag) async {
    final output = await tools.gitOutput([
      'ls-remote',
      '--tags',
      'origin',
      '$tag*',
    ]);
    return parseRemoteTagCommit(output, tag);
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

String? parseRemoteTagCommit(String output, String tag) {
  if (output == 'unknown' || output.trim().isEmpty) return null;

  String? directTag;

  for (final line in output.trim().split('\n')) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) continue;

    final sha = parts[0];
    final ref = parts[1];

    if (ref == 'refs/tags/$tag^{}') return sha;
    if (ref == 'refs/tags/$tag') directTag = sha;
  }

  return directTag;
}
