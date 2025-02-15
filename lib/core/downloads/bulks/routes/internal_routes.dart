// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../configs/ref.dart';
import '../../../foundation/toast.dart';
import '../../../router.dart';
import '../../downloader/download_utils.dart';
import '../../l10n.dart';
import '../pages/bulk_download_completed_page.dart';
import '../pages/bulk_download_saved_task_page.dart';
import '../pages/create_bulk_download_task_sheet.dart';

Future<void> goToBulkDownloadCompletedPage(BuildContext context) async {
  await Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const BulkDownloadCompletedPage(),
    ),
  );
}

Future<void> goToBulkDownloadSavedTasksPage(BuildContext context) async {
  await Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const BulkDownloadSavedTaskPage(),
    ),
  );
}

void goToNewBulkDownloadTaskPage(
  WidgetRef ref,
  BuildContext context, {
  required List<String>? initialValue,
}) {
  final config = ref.readConfigAuth;

  if (!config.booruType.canDownloadMultipleFiles) {
    showBulkDownloadUnsupportErrorToast(context);
    return;
  }

  final prevRouteName = ModalRoute.of(context)?.settings.name;

  showModalBottomSheet(
    context: context,
    routeSettings: const RouteSettings(name: 'bulk_download_create'),
    builder: (_) => CreateBulkDownloadTaskSheet(
      initialValue: initialValue,
      title: DownloadTranslations.bulkDownloadNewDownloadTitle.tr(),
      onSubmitted: (_, isQueue) {
        if (prevRouteName != kBulkdownload) {
          showSimpleSnackBar(
            context: context,
            content: Text(
              isQueue ? 'Created' : 'Download started',
            ),
            action: SnackBarAction(
              label: 'View',
              textColor: Theme.of(context).colorScheme.surface,
              onPressed: () {
                context.pushNamed(kBulkdownload);
              },
            ),
          );
        }
      },
    ),
  );
}
