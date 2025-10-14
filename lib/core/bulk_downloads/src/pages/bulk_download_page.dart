// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../boorus/booru/types.dart';
import '../../../configs/config/providers.dart';
import '../../../themes/theme/types.dart';
import '../../../widgets/widgets.dart';
import '../providers/bulk_download_notifier.dart';
import '../providers/saved_download_task_provider.dart';
import '../routes/internal_routes.dart';
import '../widgets/saved_task_list_tile.dart';
import '../widgets/tasks/task_tile.dart';

class BulkDownloadPage extends ConsumerWidget {
  const BulkDownloadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return config.booruType == BooruType.zerochan ||
            config.booruType == BooruType.eshuushuu
        ? Scaffold(
            appBar: AppBar(
              title: Text(context.t.sideMenu.bulk_download),
            ),
            body: Center(
              child: Text(
                'Temporarily disabled due to an issue with getting the download link'
                    .hc,
              ),
            ),
          )
        : const BulkDownloadPageInternal();
  }
}

class BulkDownloadPageInternal extends StatelessWidget {
  const BulkDownloadPageInternal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                Text(context.t.sideMenu.bulk_download),
                Consumer(
                  builder: (_, ref, _) => constraints.maxWidth >= 432
                      ? _buildCreateButton(ref, dense: true)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          actions: [
            Consumer(
              builder: (_, ref, _) {
                final hasUnseen = ref.watch(
                  bulkDownloadProvider.select(
                    (state) => state.hasUnseenFinishedSessions,
                  ),
                );
                final notifier = ref.watch(bulkDownloadProvider.notifier);

                return IconButton(
                  icon: Badge(
                    isLabelVisible: hasUnseen,
                    smallSize: 8,
                    child: const Icon(Symbols.history),
                  ),
                  onPressed: () {
                    goToBulkDownloadCompletedPage(ref);
                    notifier.clearUnseenFinishedSessions();
                  },
                );
              },
            ),
            Consumer(
              builder: (_, ref, _) {
                return IconButton(
                  icon: const Icon(Symbols.bookmark),
                  onPressed: () {
                    goToBulkDownloadSavedTasksPage(ref);
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer(
          builder: (_, ref, _) {
            final ready = ref.watch(
              bulkDownloadProvider.select((state) => state.ready),
            );

            return SafeArea(
              child: ready
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Expanded(
                          child: BulkDownloadActionSessions(),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return constraints.maxWidth < 600
                                ? _buildCreateButton(ref)
                                : const SizedBox.shrink();
                          },
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCreateButton(
    WidgetRef ref, {
    bool dense = false,
  }) {
    return PrimaryButton(
      dense: dense,
      onPressed: () {
        goToNewBulkDownloadTaskPage(
          ref,
          ref.context,
          initialValue: null,
          showStartNotification: false,
        );
      },
      child: Text(
        dense
            ? ref.context.t.bulk_downloads.actions.create
            : ref.context.t.bulk_downloads.actions.new_download,
      ),
    );
  }
}

class BulkDownloadActionSessions extends ConsumerWidget {
  const BulkDownloadActionSessions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(bulkDownloadSessionsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return sessions.isNotEmpty
        ? ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) => BulkDownloadTaskTile(
              session: sessions[index],
            ),
          )
        : ref
              .watch(savedDownloadTasksProvider)
              .when(
                data: (tasks) => tasks.isEmpty
                    ? Center(
                        child: Text(
                          context.t.download.no_active_sessions,
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.hintColor,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 60,
                            child: Center(
                              child: Text(
                                context.t.download.no_active_sessions,
                                style: textTheme.titleSmall?.copyWith(
                                  color: colorScheme.hintColor,
                                ),
                              ),
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            child: Text(
                              context.t.bulk_downloads.templates.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              itemCount: tasks.length,
                              itemBuilder: (context, index) =>
                                  SavedTaskListTile(
                                    savedTask: tasks[index],
                                    enableTap: false,
                                  ),
                            ),
                          ),
                        ],
                      ),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
  }
}
