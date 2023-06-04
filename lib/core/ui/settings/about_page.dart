// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/package_info_provider.dart';
import 'package:boorusama/core/provider.dart';

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
      applicationLegalese: '\u{a9} 2020-2023 Nguyen Duc Khoa',
      applicationName: appInfo.appName,
    );
  }
}
