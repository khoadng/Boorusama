import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../io/process_runner.dart';
import '../../project/project.dart';

final class PlayReleaseConfig {
  const PlayReleaseConfig({
    required this.serviceAccountJsonFile,
    required this.packageName,
  });

  final File serviceAccountJsonFile;
  final String packageName;
}

final class PlayReleaseConfigResolver {
  const PlayReleaseConfigResolver({
    required this.root,
    required this.project,
  });

  final Directory root;
  final Project project;

  PlayReleaseConfig resolve() {
    final serviceAccountJson = project.env['GOOGLE_PLAY_SERVICE_ACCOUNT_JSON'];
    if (serviceAccountJson == null || serviceAccountJson.isEmpty) {
      throw const ProcessFailure(
        'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON is not configured.',
      );
    }

    final serviceAccountJsonFile = File(_resolveRootPath(serviceAccountJson));
    if (!serviceAccountJsonFile.existsSync()) {
      throw ProcessFailure(
        'Google Play service account file does not exist: $serviceAccountJson.',
      );
    }
    if (!_isServiceAccountJson(serviceAccountJsonFile)) {
      throw const ProcessFailure(
        'Google Play service account JSON is invalid or is not a service account.',
      );
    }

    final packageName = project.env['GOOGLE_PLAY_PACKAGE_NAME'];
    if (packageName == null || packageName.isEmpty) {
      throw const ProcessFailure('GOOGLE_PLAY_PACKAGE_NAME is not configured.');
    }

    final androidApplicationId = _androidApplicationId();
    if (packageName != androidApplicationId) {
      throw ProcessFailure(
        'GOOGLE_PLAY_PACKAGE_NAME does not match Android applicationId: $packageName != $androidApplicationId.',
      );
    }

    return PlayReleaseConfig(
      serviceAccountJsonFile: serviceAccountJsonFile,
      packageName: packageName,
    );
  }

  String? androidApplicationId() => _androidApplicationId();

  bool isServiceAccountJson(File file) => _isServiceAccountJson(file);

  String _resolveRootPath(String value) {
    if (p.isAbsolute(value)) return value;
    return p.join(root.path, value);
  }

  bool _isServiceAccountJson(File file) {
    if (!file.existsSync()) return false;

    try {
      final json = jsonDecode(file.readAsStringSync());
      if (json is! Map<String, Object?>) return false;
      return json['type'] == 'service_account' &&
          _isNonEmptyString(json['client_email']) &&
          _isNonEmptyString(json['private_key']);
    } on Object {
      return false;
    }
  }

  String? _androidApplicationId() {
    final gradleFile = File('${root.path}/android/app/build.gradle.kts');
    if (!gradleFile.existsSync()) return null;

    final match = RegExp(
      r'applicationId\s*=\s*"([^"]+)"',
    ).firstMatch(gradleFile.readAsStringSync());
    return match?.group(1);
  }

  bool _isNonEmptyString(Object? value) {
    return value is String && value.isNotEmpty;
  }
}
