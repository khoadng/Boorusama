// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../foundation/toast.dart';
import '../../../widgets/widgets.dart';
import '../providers/bulk_download_notifier.dart';
import '../providers/saved_download_task_provider.dart';
import '../types/download_configs.dart';
import '../types/saved_download_task.dart';
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
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final savedTask = tasks[index];

                      final downloadConfigs = DownloadConfigs(
                        onDownloadStart: () {
                          showSimpleSnackBar(
                            context: context,
                            content: Text(
                              'Started downloading ${savedTask.name}',
                            ),
                          );
                        },
                      );

                      return ListTile(
                        title: Text(savedTask.name ?? 'Untitled'),
                        subtitle: Text(
                          savedTask.task.tags ?? 'No tags',
                        ),
                        onTap: () async {
                          await navigator.push(
                            CupertinoPageRoute(
                              builder: (context) =>
                                  BulkDownloadEditSavedTaskPage(
                                savedTask: savedTask,
                              ),
                            ),
                          );
                          ref.invalidate(savedDownloadTasksProvider);
                        },
                        trailing: _ActionButton(
                          icon: const Icon(
                            FontAwesomeIcons.play,
                          ),
                          onPressed: () {
                            notifier.runSavedTask(
                              savedTask,
                              downloadConfigs: downloadConfigs,
                            );
                          },
                        ),
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => _ModalOptions(
                              savedTask: savedTask,
                              onDelete: () async {
                                await notifier.deleteSavedTask(savedTask.id);
                                ref.invalidate(savedDownloadTasksProvider);
                              },
                              onRun: () {
                                notifier.runSavedTask(
                                  savedTask,
                                  downloadConfigs: downloadConfigs,
                                );
                                ref.invalidate(savedDownloadTasksProvider);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _ModalOptions extends StatelessWidget {
  const _ModalOptions({
    required this.savedTask,
    required this.onDelete,
    required this.onRun,
  });

  final SavedDownloadTask savedTask;
  final void Function() onDelete;
  final void Function() onRun;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const DragLine(),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Run'),
            onTap: () {
              onRun();
              navigator.pop();
            },
          ),
          ListTile(
            title: const Text('Delete'),
            onTap: () {
              onDelete();
              navigator.pop();
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircularIconButton(
      padding: const EdgeInsets.all(8),
      backgroundColor: colorScheme.surfaceContainer,
      icon: Theme(
        data: ThemeData(
          iconTheme: IconThemeData(
            color: colorScheme.onSurfaceVariant,
            fill: 1,
            size: 18,
          ),
        ),
        child: icon,
      ),
      onPressed: onPressed,
    );
  }
}
