// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/app_info.dart';
import 'package:boorusama/foundation/package_info.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    final appInfo = ref.watch(appInfoProvider);

    return AboutDialog(
      applicationIcon: Image.asset(
        'assets/icon/icon-512x512.png',
        width: 64,
        height: 64,
      ),
      applicationVersion: packageInfo.version,
      applicationLegalese: _legaleseFromAppInfo(appInfo),
      applicationName: appInfo.appName,
    );
  }
}

String _legaleseFromAppInfo(AppInfo appInfo) =>
    '\u{a9} ${appInfo.copyrightYearRange.start}-${appInfo.copyrightYearRange.end} ${appInfo.author}';
