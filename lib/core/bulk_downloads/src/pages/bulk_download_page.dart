// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../configs/ref.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../providers/bulk_download_notifier.dart';
import '../providers/saved_download_task_provider.dart';
import '../routes/internal_routes.dart';
import '../types/l10n.dart';
import '../widgets/bulk_download_task_tile.dart';
import '../widgets/saved_task_list_tile.dart';

class BulkDownloadPage extends ConsumerWidget {
  const BulkDownloadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return config.booruType == BooruType.zerochan
        ? Scaffold(
            appBar: AppBar(
              title: const Text(DownloadTranslations.title).tr(),
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

class BulkDownloadPageInternal extends StatelessWidget {
  const BulkDownloadPageInternal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(DownloadTranslations.title).tr(),
          actions: [
            Consumer(
              builder: (_, ref, __) {
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
              builder: (_, ref, __) {
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
          builder: (_, ref, __) {
            final ready =
                ref.watch(bulkDownloadProvider.select((state) => state.ready));

            return SafeArea(
              child: ready
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Expanded(
                          child: BulkDownloadActionSessions(),
                        ),
                        PrimaryButton(
                          onPressed: () {
                            goToNewBulkDownloadTaskPage(
                              ref,
                              context,
                              initialValue: null,
                              showStartNotification: false,
                            );
                          },
                          child: const Text(
                            DownloadTranslations.create,
                          ).tr(),
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
        : ref.watch(savedDownloadTasksProvider).when(
              data: (tasks) => tasks.isEmpty
                  ? Center(
                      child: Text(
                        DownloadTranslations.empty,
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
                              DownloadTranslations.empty,
                              style: textTheme.titleSmall?.copyWith(
                                color: colorScheme.hintColor,
                              ),
                            ).tr(),
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: const Text(
                            'Templates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ).tr(),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) => SavedTaskListTile(
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
