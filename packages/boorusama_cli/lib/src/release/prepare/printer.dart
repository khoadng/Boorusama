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
      _printGooglePlayInfo(plan);
    }
  }

  String _checkLine(bool passed, String label) {
    final status = passed ? _green('OK') : _red('FAIL');
    return '    [$status] $label';
  }

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
    final productionMaxVersionCode =
        plan.googlePlay.api.productionMaxVersionCode;
    if (productionMaxVersionCode == null) {
      return 'planned versionCode available on Google Play production';
    }
    return 'production versionCode: $productionMaxVersionCode -> $plannedVersionCode';
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
}
