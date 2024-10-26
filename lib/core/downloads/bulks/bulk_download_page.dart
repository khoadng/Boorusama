// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import '../l10n.dart';

class BulkDownloadPage extends ConsumerWidget {
  const BulkDownloadPage({
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
