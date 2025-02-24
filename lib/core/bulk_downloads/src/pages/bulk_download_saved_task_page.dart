// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import '../providers/bulk_download_notifier.dart';
import '../providers/saved_download_task_provider.dart';
import '../providers/saved_task_lock_notifier.dart';
import '../types/bulk_download_error.dart';
import '../types/l10n.dart';
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
          title: const Text(DownloadTranslations.templates).tr(),
          actions: const [
            _AddButton(),
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
                      DownloadTranslations.emptyTemplates,
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

class _AddButton extends ConsumerWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bulkNotifier = ref.watch(bulkDownloadProvider.notifier);
    final hasSavedTaskLocked =
        ref.watch(hasAnySavedTaskLockedProvider).valueOrNull;

    return IconButton(
      icon: const Icon(Symbols.add),
      onPressed: () {
        if (hasSavedTaskLocked != true) {
          showBooruModalBottomSheet(
            context: context,
            builder: (context) => BulkDownloadEditSavedTaskPage(
              savedTask: SavedDownloadTask.empty(),
            ),
          );
        } else {
          bulkNotifier.setError(const NonPremiumSavedTaskLimitError());
        }
      },
    );
  }
}
