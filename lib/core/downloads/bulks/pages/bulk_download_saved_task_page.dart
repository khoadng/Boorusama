// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import '../providers/saved_download_task_provider.dart';
import '../types/saved_download_task.dart';
import '../widgets/saved_task_list_tile.dart';
import 'bulk_download_edit_saved_task_page.dart';

class BulkDownloadSavedTaskPage extends ConsumerWidget {
  const BulkDownloadSavedTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(savedDownloadTasksProvider);
    final notifier = ref.watch(savedDownloadTasksProvider.notifier);

    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Templates').tr(),
          actions: [
            IconButton(
              icon: const Icon(Symbols.add),
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (context) => BulkDownloadEditSavedTaskPage(
                  savedTask: SavedDownloadTask.empty(),
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          child: tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (tasks) => tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No templates',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) => SavedTaskListTile(
                      savedTask: tasks[index],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
