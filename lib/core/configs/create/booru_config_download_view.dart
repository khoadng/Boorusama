// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/foundation/theme.dart';

class BooruConfigDownloadView extends ConsumerWidget {
  const BooruConfigDownloadView({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);
    final customDownloadFileNameFormat = ref.watch(editBooruConfigProvider(id)
        .select((value) => value.customDownloadFileNameFormat));
    final customDownloadLocation = ref.watch(
        editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
            .select((value) => value.customDownloadLocation));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DownloadFolderSelectorSection(
            storagePath: customDownloadLocation,
            deviceInfo: ref.watch(deviceInfoProvider),
            onPathChanged: (path) =>
                ref.editNotifier.updateCustomDownloadLocation(path),
            title: 'Download location',
          ),
          const SizedBox(height: 4),
          Text(
            'Leave empty to use the download location in settings.',
            style: ref.context.textTheme.titleSmall?.copyWith(
              color: ref.context.colorScheme.hintColor,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          CustomDownloadFileNameSection(
            config: config,
            format: customDownloadFileNameFormat,
            onIndividualDownloadChanged: (value) =>
                ref.editNotifier.updateCustomDownloadFileNameFormat(value),
            onBulkDownloadChanged: (value) =>
                ref.editNotifier.updateCustomBulkDownloadFileNameFormat(value),
          ),
        ],
      ),
    );
  }
}
