// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import '../providers/saved_download_task_provider.dart';
import '../widgets/saved_task_list_tile.dart';

class BulkDownloadSavedTaskPage extends ConsumerWidget {
  const BulkDownloadSavedTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(savedDownloadTasksProvider);

    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Templates').tr(),
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(savedDownloadTasksProvider.future),
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
