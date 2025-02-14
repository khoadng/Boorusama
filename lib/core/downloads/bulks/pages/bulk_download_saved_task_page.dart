// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import '../providers/bulk_download_notifier.dart';
import '../providers/saved_download_task_provider.dart';
import 'bulk_download_edit_saved_task_page.dart';

class BulkDownloadSavedTaskPage extends ConsumerWidget {
  const BulkDownloadSavedTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(savedDownloadTasksProvider);
    final notifier = ref.watch(bulkDownloadProvider.notifier);
    final navigator = Navigator.of(context);

    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved Tasks'),
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(savedDownloadTasksProvider.future),
          child: tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (tasks) => tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No saved tasks',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final savedTask = tasks[index];
                      return ListTile(
                        title: Text(savedTask.name ?? 'Unnamed Task'),
                        subtitle: Text(
                          savedTask.task.tags ?? 'No tags',
                        ),
                        isThreeLine: true,
                        trailing: BooruPopupMenuButton(
                          onSelected: (value) async {
                            if (value == 'run') {
                              await notifier.runSavedTask(savedTask);
                            } else if (value == 'delete') {
                              await notifier.deleteSavedTask(savedTask.id);
                              ref.invalidate(savedDownloadTasksProvider);
                            } else if (value == 'edit') {
                              await navigator.push(
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      BulkDownloadEditSavedTaskPage(
                                    savedTask: savedTask,
                                  ),
                                ),
                              );
                              ref.invalidate(savedDownloadTasksProvider);
                            }
                          },
                          itemBuilder: const {
                            'run': Text('Run'),
                            'edit': Text('Edit'),
                            'delete': Text('Delete'),
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
