// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../boorus.dart';
import '../../configs/ref.dart';
import '../../widgets/widgets.dart';
import '../l10n.dart';
import 'bulk_download_notifier.dart';
import 'bulk_download_task_tile.dart';
import 'create_bulk_download_task_sheet.dart';

class BulkDownloadPage extends ConsumerWidget {
  const BulkDownloadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return config.booruType == BooruType.zerochan
        ? Scaffold(
            appBar: AppBar(
              title: const Text(DownloadTranslations.bulkDownloadTitle).tr(),
            ),
            body: const Center(
              child: Text(
                'Temporarily disabled due to an issue with getting the download link',
              ),
            ),
          )
        : const BulkDownloadPageInternal();
  }
}

class BulkDownloadPageInternal extends ConsumerWidget {
  const BulkDownloadPageInternal({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(bulkdownloadProvider);

    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(DownloadTranslations.bulkDownloadTitle).tr(),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: tasks.isNotEmpty
                    ? ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) => BulkDownloadTaskTile(
                          taskId: tasks[index].id,
                        ),
                      )
                    : Center(
                        child: const Text(
                          DownloadTranslations.bulkDownloadEmpty,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ).tr(),
                      ),
              ),
              Container(
                margin: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: () {
                    goToNewBulkDownloadTaskPage(
                      ref,
                      context,
                      initialValue: null,
                    );
                  },
                  child:
                      const Text(DownloadTranslations.bulkDownloadCreate).tr(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
