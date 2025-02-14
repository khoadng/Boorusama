// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../configs/ref.dart';
import '../../../widgets/widgets.dart';
import '../../bulks.dart';
import '../../l10n.dart';
import '../../routes/route_utils.dart';
import '../providers/bulk_download_notifier.dart';
import 'bulk_download_completed_page.dart';
import 'bulk_download_saved_task_page.dart';

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

class BulkDownloadPageInternal extends StatelessWidget {
  const BulkDownloadPageInternal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(DownloadTranslations.bulkDownloadTitle).tr(),
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
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const BulkDownloadCompletedPage(),
                      ),
                    );
                    notifier.clearUnseenFinishedSessions();
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Symbols.bookmark),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const BulkDownloadSavedTaskPage(),
                  ),
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
                            child: const Text(
                              DownloadTranslations.bulkDownloadCreate,
                            ).tr(),
                          ),
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
    final sessiosn = ref.watch(bulkDownloadSessionsProvider);

    return sessiosn.isNotEmpty
        ? ListView.builder(
            itemCount: sessiosn.length,
            itemBuilder: (context, index) => BulkDownloadTaskTile(
              session: sessiosn[index],
            ),
          )
        : Center(
            child: const Text(
              DownloadTranslations.bulkDownloadEmpty,
              style: TextStyle(fontWeight: FontWeight.bold),
            ).tr(),
          );
  }
}
