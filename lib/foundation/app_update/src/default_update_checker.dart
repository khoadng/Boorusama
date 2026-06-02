// Package imports:
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import '../../platform.dart';
import 'github_release_update_checker.dart';
import 'play_store_update_checker.dart';
import 'types/app_update_checker.dart';

const _kReleaseChannel = String.fromEnvironment('RELEASE_CHANNEL');
const _kReleaseChannelGithub = 'github';
const _kReleaseChannelPlay = 'play';

const kGitHubUpdateManifestUrl =
    'https://github.com/khoadng/Boorusama/releases/latest/download/boorusama-update.json';

AppUpdateChecker createDefaultAppUpdateChecker(PackageInfo packageInfo) {
  return switch (_kReleaseChannel) {
    _kReleaseChannelPlay when isAndroid() => PlayStoreUpdateChecker(
      packageInfo: packageInfo,
      countryCode: 'US',
      languageCode: 'en',
    ),
    _kReleaseChannelGithub when isNotWeb() => GitHubReleaseUpdateChecker(
      packageInfo: packageInfo,
      manifestUrl: kGitHubUpdateManifestUrl,
    ),
    _ => UnsupportedPlatformChecker(),
  };
}
