// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../downloads/widgets.dart';
import '../../../../info/device_info.dart';
import '../../../../theme.dart';
import '../../../create/providers.dart';
import '../widgets/custom_download_file_name_section.dart';

class BooruConfigDownloadView extends ConsumerWidget {
  const BooruConfigDownloadView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final id = ref.watch(editBooruConfigIdProvider);
    final customDownloadFileNameFormat = ref.watch(
      editBooruConfigProvider(id)
          .select((value) => value.customDownloadFileNameFormat),
    );
    final customDownloadLocation = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
          .select((value) => value.customDownloadLocation),
    );

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
            title: const Text(
              'Download location',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Leave empty to use the download location in settings.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.hintColor,
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
