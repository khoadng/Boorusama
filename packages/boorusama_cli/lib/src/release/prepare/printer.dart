import 'dart:io';

import 'plan.dart';

final class ReleasePreparePrinter {
  const ReleasePreparePrinter();

  void printPlan(ReleasePreparePlan plan, {required bool apply}) {
    print('Release prepare plan');
    print('');
    print('Release:');
    print('  version: ${plan.versionName}');
    print('  branch:  ${plan.branch}');
    print('  tag:     ${plan.tag}');
    print('');
    print('Checks:');
    _printLocalChecks(plan);
    _printGooglePlayChecks(plan);
    _printGithubChecks(plan);
    print('');
    print('Mode: ${apply ? 'apply' : 'dry-run'}');
  }

  void printDiffPreview(ReleasePreparePlan plan) {
    if (plan.changes.isEmpty) return;

    print('');
    print('Planned file changes:');
    for (final change in plan.changes) {
      print('diff -- ${change.path}');
      print(_red('-${change.before}'));
      print(_green('+${change.after}'));
    }
  }

  void _printLocalChecks(ReleasePreparePlan plan) {
    print('  Local:');
    print(_checkLine(plan.workingTreeClean, 'working tree clean'));
    print(
      _checkLine(
        !plan.localTagExists && !plan.remoteTagExists,
        _tagLabel(plan),
      ),
    );
    print(
      _checkLine(
        plan.changelogStatus != ChangelogStatus.missing,
        'changelog section: ${plan.changelogStatus.label}',
      ),
    );
    print(_infoLine(_branchStatus(plan)));
    print('');
  }

  void _printGooglePlayChecks(ReleasePreparePlan plan) {
    print('  Google Play:');
    print(
      _checkLine(
        plan.googlePlay.serviceAccountReady,
        _googlePlayServiceAccountLabel(plan),
      ),
    );
    print(
      _checkLine(
        plan.googlePlay.packageNameMatchesAndroid,
        _googlePlayPackageNameLabel(plan),
      ),
    );
    if (plan.googlePlay.serviceAccountReady &&
        plan.googlePlay.packageNameMatchesAndroid) {
      print(
        _checkLine(
          plan.googlePlay.api.succeeded &&
              plan.googlePlay.api.productionTrackReadable,
          _googlePlayApiLabel(plan),
        ),
      );
      print(
        _checkLine(
          plan.googlePlay.api.plannedVersionCodeIsNewer(
            _plannedVersionCode(plan),
          ),
          _googlePlayVersionCodeLabel(plan),
        ),
      );
      print(_versionNamePolicyLine(plan));
      _printGooglePlayInfo(plan);
    }
  }

  void _printGithubChecks(ReleasePreparePlan plan) {
    print('');
    print('  GitHub:');
    print(_checkLine(plan.github.repoConfigured, _githubRepoLabel(plan)));
    print(
      _checkLine(
        plan.github.workflowFileExists,
        'workflow file: ${plan.github.workflow}',
      ),
    );
    print(_checkLine(plan.github.ghInstalled, 'GitHub CLI installed'));

    if (plan.github.repoConfigured &&
        plan.github.workflowFileExists &&
        plan.github.ghInstalled) {
      print(_checkLine(plan.github.authenticated, 'GitHub CLI authenticated'));
      print(
        _checkLine(
          plan.github.workflowReadable,
          'workflow readable on ${plan.github.repo}',
        ),
      );
      print(
        _checkLine(
          plan.github.releaseLookupSucceeded && !plan.github.releaseExists,
          _githubReleaseLabel(plan),
        ),
      );
      if (plan.github.error != null) {
        print(_infoLine('GitHub: ${plan.github.error}'));
      }
    }
  }

  String _checkLine(bool passed, String label) {
    final status = passed ? _green('OK') : _red('FAIL');
    return '    [$status] $label';
  }

  String _warningLine(String label) => '    [${_yellow('WARN')}] $label';

  String _infoLine(String label) => '    [INFO] $label';

  String _tagLabel(ReleasePreparePlan plan) {
    if (plan.localTagExists && plan.remoteTagExists) {
      return 'tag ${plan.tag} available locally and on origin';
    }
    if (plan.localTagExists) {
      return 'tag ${plan.tag} available locally';
    }
    if (plan.remoteTagExists) {
      return 'tag ${plan.tag} available on origin';
    }
    return 'tag ${plan.tag} available';
  }

  String _branchStatus(ReleasePreparePlan plan) {
    if (plan.localBranchExists) {
      return 'branch ${plan.branch} exists locally';
    }
    if (plan.remoteBranchExists) {
      return 'branch ${plan.branch} exists on origin';
    }
    return 'branch ${plan.branch} will be created';
  }

  String _googlePlayServiceAccountLabel(ReleasePreparePlan plan) {
    if (!plan.googlePlay.serviceAccountJsonConfigured) {
      return 'Google Play service account configured';
    }
    return 'Google Play service account file valid';
  }

  String _googlePlayPackageNameLabel(ReleasePreparePlan plan) {
    final packageName = plan.googlePlay.packageName;
    final androidApplicationId = plan.googlePlay.androidApplicationId;
    if (packageName == null || packageName.isEmpty) {
      return 'Google Play package name configured';
    }
    if (androidApplicationId == null || androidApplicationId.isEmpty) {
      return 'Google Play package name matches Android applicationId';
    }
    return 'Google Play package name matches $androidApplicationId';
  }

  String _googlePlayApiLabel(ReleasePreparePlan plan) {
    if (!plan.googlePlay.api.checked) {
      return 'Google Play API check skipped';
    }
    return 'API can read production';
  }

  String _googlePlayVersionCodeLabel(ReleasePreparePlan plan) {
    final plannedVersionCode = _plannedVersionCode(plan);
    final maxVersionCode = plan.googlePlay.api.maxVersionCode;
    if (maxVersionCode == null) {
      return 'planned versionCode available on Google Play';
    }
    final track = plan.googlePlay.api.maxVersionCodeTrack;
    final source = track == null ? 'Google Play' : 'Google Play $track';
    return '$source versionCode: $maxVersionCode -> $plannedVersionCode';
  }

  String _versionNamePolicyLine(ReleasePreparePlan plan) {
    final latest = plan.googlePlay.api.productionLatestVersionName;
    final label = latest == null
        ? 'production versionName readable'
        : 'production versionName: $latest -> ${plan.versionName}';
    return switch (plan.versionNamePolicy) {
      VersionNamePolicy.unknown => _infoLine(label),
      VersionNamePolicy.ok => _checkLine(true, label),
      VersionNamePolicy.warnJump => _warningLine(
        '$label (more than one version step)',
      ),
      VersionNamePolicy.blocked => _checkLine(false, label),
    };
  }

  String _githubRepoLabel(ReleasePreparePlan plan) {
    final repo = plan.github.repo;
    if (repo == null || repo.isEmpty) {
      return 'repository configured';
    }
    return 'repository: $repo';
  }

  String _githubReleaseLabel(ReleasePreparePlan plan) {
    if (plan.github.releaseExists) {
      return 'GitHub release ${plan.tag} does not exist';
    }
    return 'GitHub release ${plan.tag} available';
  }

  void _printGooglePlayInfo(ReleasePreparePlan plan) {
    final api = plan.googlePlay.api;
    if (!api.succeeded) return;

    final latest = [
      api.productionLatestReleaseName,
      api.productionLatestReleaseStatus,
    ].whereType<String>().join(', ');
    if (latest.isNotEmpty) {
      print(_infoLine('latest production: $latest'));
    }
    if (api.defaultLanguage != null && api.listingLanguages.isNotEmpty) {
      print(
        _infoLine(
          'listing: ${api.defaultLanguage}, ${api.listingLanguages.length} locale(s)',
        ),
      );
    }
  }

  int? _plannedVersionCode(ReleasePreparePlan plan) {
    final nextFullVersion = plan.nextFullVersion;
    final separatorIndex = nextFullVersion?.lastIndexOf('+') ?? -1;
    if (nextFullVersion == null || separatorIndex < 0) {
      return null;
    }
    return int.tryParse(nextFullVersion.substring(separatorIndex + 1));
  }

  String _red(String value) =>
      stdout.hasTerminal ? '\x1B[0;31m$value\x1B[0m' : value;

  String _green(String value) =>
      stdout.hasTerminal ? '\x1B[0;32m$value\x1B[0m' : value;

  String _yellow(String value) =>
      stdout.hasTerminal ? '\x1B[0;33m$value\x1B[0m' : value;
}
