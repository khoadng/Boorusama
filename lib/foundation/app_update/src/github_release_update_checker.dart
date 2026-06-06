// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'types/app_update_checker.dart';
import 'types/update_status.dart';

class GitHubReleaseUpdateChecker implements AppUpdateChecker {
  GitHubReleaseUpdateChecker({
    required this.packageInfo,
    required this.manifestUrl,
    Client? client,
  }) : _client = client ?? Client();

  final PackageInfo packageInfo;
  final String manifestUrl;
  final Client _client;

  @override
  Future<UpdateStatus> checkForUpdate() async {
    try {
      final response = await _client.get(Uri.parse(manifestUrl));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return UpdateError(
          'GitHub update manifest check failed: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const UpdateError('Invalid GitHub update manifest');
      }

      final manifest = GitHubUpdateManifest.tryParse(decoded);
      if (manifest == null) {
        return const UpdateError('Invalid GitHub update manifest');
      }

      final latestVersion = Version.tryParse(manifest.version);
      final currentVersion = Version.tryParse(packageInfo.version);
      if (latestVersion == null || currentVersion == null) {
        return const UpdateError('Failed to parse update version');
      }

      if (currentVersion < latestVersion) {
        return UpdateAvailable(
          storeVersion: latestVersion.toString(),
          currentVersion: currentVersion.toString(),
          releaseNotes: manifest.notes,
          storeUrl: manifest.releaseUrl,
        );
      }

      return const UpdateNotAvailable();
    } on Exception catch (e) {
      return UpdateError(e);
    }
  }
}

class GitHubUpdateManifest {
  const GitHubUpdateManifest({
    required this.version,
    required this.releaseUrl,
    required this.notes,
  });

  final String version;
  final String releaseUrl;
  final String notes;

  static GitHubUpdateManifest? tryParse(Map<String, dynamic> json) {
    final version = json['version'];
    final releaseUrl = json['releaseUrl'];
    final notes = json['notes'];

    if (version is! String || version.isEmpty) return null;
    if (releaseUrl is! String || releaseUrl.isEmpty) return null;

    return GitHubUpdateManifest(
      version: version,
      releaseUrl: releaseUrl,
      notes: notes is String ? notes : '',
    );
  }
}
