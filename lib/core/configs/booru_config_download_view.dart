// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/custom_download_file_name_section.dart';
import 'configs.dart';

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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
