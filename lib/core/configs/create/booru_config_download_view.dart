// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class BooruConfigDownloadView extends ConsumerWidget {
  const BooruConfigDownloadView({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customDownloadFileNameFormat =
        ref.watch(customDownloadFileNameFormatProvider);
    final customDownloadLocation = ref.watch(customDownloadLocationProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DownloadFolderSelectorSection(
            storagePath: customDownloadLocation,
            deviceInfo: ref.watch(deviceInfoProvider),
            onPathChanged: (path) => ref.updateCustomDownloadLocation(path),
            title: 'Download location',
          ),
          const SizedBox(height: 4),
          Text(
            'Leave empty to use the download location in settings.',
            style: ref.context.textTheme.titleSmall?.copyWith(
              color: ref.context.theme.hintColor,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          CustomDownloadFileNameSection(
            config: config,
            format: customDownloadFileNameFormat,
            onIndividualDownloadChanged: (value) =>
                ref.updateCustomDownloadFileNameFormat(value),
            onBulkDownloadChanged: (value) =>
                ref.updateCustomBulkDownloadFileNameFormat(value),
          ),
        ],
      ),
    );
  }
}
