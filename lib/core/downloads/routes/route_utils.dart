// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../boorus/booru/booru.dart';
import '../../configs/ref.dart';
import '../../foundation/toast.dart';
import '../../router.dart';
import '../bulks/pages/create_bulk_download_task_sheet.dart';
import '../downloader/download_utils.dart';
import '../l10n.dart';

Future<void> goToBulkDownloadPage(
  BuildContext context,
  List<String>? tags, {
  required WidgetRef ref,
}) async {
  if (tags != null) {
    goToNewBulkDownloadTaskPage(
      ref,
      context,
      initialValue: tags,
    );
  } else {
    unawaited(context.pushNamed(kBulkdownload));
  }
}

void goToDownloadManagerPage(
  BuildContext context,
) {
  context.push(
    Uri(
      path: '/download_manager',
    ).toString(),
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
              isQueue ? 'Added' : 'Download started',
            ),
            action: SnackBarAction(
              label: 'View',
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
