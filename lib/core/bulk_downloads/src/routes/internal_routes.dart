// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../downloads/downloader/providers.dart';
import '../../../router.dart';
import '../../../widgets/widgets.dart';
import '../pages/create_download_options_sheet.dart';

Future<void> goToBulkDownloadCompletedPage(WidgetRef ref) async {
  await ref.router.push(
    Uri(
      pathSegments: [
        '',
        'bulk_downloads',
        'completed',
      ],
    ).toString(),
  );
}

Future<void> goToBulkDownloadSavedTasksPage(WidgetRef ref) async {
  await ref.router.push(
    Uri(
      pathSegments: [
        '',
        'bulk_downloads',
        'saved',
      ],
    ).toString(),
  );
}

void goToNewBulkDownloadTaskPage(
  WidgetRef ref,
  BuildContext context, {
  required List<String>? initialValue,
  bool showStartNotification = true,
}) {
  final config = ref.readConfigAuth;

  if (!config.booruType.canDownloadMultipleFiles) {
    showBulkDownloadUnsupportErrorToast(context);
    return;
  }

  showBooruModalBottomSheet(
    context: context,
    routeSettings: const RouteSettings(name: 'bulk_download_create'),
    builder: (_) => CreateDownloadOptionsSheet(
      initialValue: initialValue,
      showStartNotification: showStartNotification,
    ),
  );
}
