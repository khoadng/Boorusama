import 'dart:io';

import '../../io/process_runner.dart';

final class GithubPrepareChecker {
  const GithubPrepareChecker({
    required this.root,
    required this.processRunner,
    this.onProgress,
  });

  final Directory root;
  final ProcessRunner processRunner;
  final void Function(String message)? onProgress;

  Future<GithubPreparePlan> check({
    required String? repo,
    required String workflow,
    required String tag,
  }) async {
    final workflowFile = _workflowFile(workflow);
    final localPlan = GithubPreparePlan(
      repo: repo,
      workflow: workflow,
      workflowFileExists: workflowFile.existsSync(),
      ghInstalled: await processRunner.exists('gh'),
      authenticated: false,
      workflowReadable: false,
      releaseLookupSucceeded: false,
      releaseExists: false,
      error: null,
    );

    if (!localPlan.repoConfigured ||
        !localPlan.workflowFileExists ||
        !localPlan.ghInstalled) {
      return localPlan;
    }

    onProgress?.call('Checking GitHub release state.');

    final auth = await _gh(['auth', 'status', '--hostname', 'github.com']);
    if (!auth.succeeded) {
      return localPlan.copyWith(
        authenticated: false,
        error: _compactError(auth),
      );
    }

    final workflowStatus = await _gh([
      'workflow',
      'view',
      workflow,
      '--repo',
      repo!,
    ]);
    if (!workflowStatus.succeeded) {
      return localPlan.copyWith(
        authenticated: true,
        workflowReadable: false,
        error: _compactError(workflowStatus),
      );
    }

    final release = await _gh([
      'release',
      'view',
      tag,
      '--repo',
      repo,
      '--json',
      'tagName',
    ]);

    if (release.succeeded) {
      return localPlan.copyWith(
        authenticated: true,
        workflowReadable: true,
        releaseLookupSucceeded: true,
        releaseExists: true,
      );
    }

    if (_isMissingRelease(release)) {
      return localPlan.copyWith(
        authenticated: true,
        workflowReadable: true,
        releaseLookupSucceeded: true,
        releaseExists: false,
      );
    }

    return localPlan.copyWith(
      authenticated: true,
      workflowReadable: true,
      releaseLookupSucceeded: false,
      releaseExists: false,
      error: _compactError(release),
    );
  }

  File _workflowFile(String workflow) {
    if (workflow.contains('/') || workflow.contains(r'\')) {
      return File('${root.path}/$workflow');
    }
    return File('${root.path}/.github/workflows/$workflow');
  }

  Future<_GithubCliResult> _gh(List<String> args) async {
    final result = await Process.run(
      'gh',
      args,
      workingDirectory: root.path,
      runInShell: Platform.isWindows,
    );
    return _GithubCliResult(
      exitCode: result.exitCode,
      stdout: result.stdout.toString(),
      stderr: result.stderr.toString(),
    );
  }

  bool _isMissingRelease(_GithubCliResult result) {
    final output = '${result.stdout}\n${result.stderr}'.toLowerCase();
    return output.contains('not found') ||
        output.contains('could not find') ||
        output.contains('no release found');
  }

  String _compactError(_GithubCliResult result) {
    final output = result.stderr.trim().isNotEmpty
        ? result.stderr.trim()
        : result.stdout.trim();
    if (output.isEmpty) return 'gh exited with ${result.exitCode}.';
    return output.split('\n').where((line) => line.trim().isNotEmpty).first;
  }
}

final class GithubPreparePlan {
  const GithubPreparePlan({
    required this.repo,
    required this.workflow,
    required this.workflowFileExists,
    required this.ghInstalled,
    required this.authenticated,
    required this.workflowReadable,
    required this.releaseLookupSucceeded,
    required this.releaseExists,
    required this.error,
  });

  final String? repo;
  final String workflow;
  final bool workflowFileExists;
  final bool ghInstalled;
  final bool authenticated;
  final bool workflowReadable;
  final bool releaseLookupSucceeded;
  final bool releaseExists;
  final String? error;

  bool get repoConfigured => repo != null && repo!.isNotEmpty;

  bool get ready =>
      repoConfigured &&
      workflowFileExists &&
      ghInstalled &&
      authenticated &&
      workflowReadable &&
      releaseLookupSucceeded &&
      !releaseExists;

  GithubPreparePlan copyWith({
    bool? authenticated,
    bool? workflowReadable,
    bool? releaseLookupSucceeded,
    bool? releaseExists,
    String? error,
  }) {
    return GithubPreparePlan(
      repo: repo,
      workflow: workflow,
      workflowFileExists: workflowFileExists,
      ghInstalled: ghInstalled,
      authenticated: authenticated ?? this.authenticated,
      workflowReadable: workflowReadable ?? this.workflowReadable,
      releaseLookupSucceeded:
          releaseLookupSucceeded ?? this.releaseLookupSucceeded,
      releaseExists: releaseExists ?? this.releaseExists,
      error: error,
    );
  }
}

final class _GithubCliResult {
  const _GithubCliResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;

  bool get succeeded => exitCode == 0;
}
