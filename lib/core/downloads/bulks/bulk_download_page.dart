// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/widgets/widgets.dart';
import 'bulk_download_task_tile.dart';
import 'create_bulk_download_task_sheet.dart';
import 'providers.dart';

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
          title: const Text('Bulk Download'),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: tasks.isNotEmpty
                    ? ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return BulkDownloadTaskTile(
                            task: task,
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'No downloads',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                  child: const Text('New download'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
