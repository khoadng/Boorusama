// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../configs/config/types.dart';
import '../../../ddos/handler/providers.dart';
import '../../../downloads/background/types.dart';
import '../../../http/client/providers.dart';
import '../../types.dart';
import '../providers/download_task_updates_notifier.dart';
import '../providers/internal_providers.dart';

class RetryAllFailedButton extends ConsumerWidget {
  const RetryAllFailedButton({
    super.key,
    this.filter,
  });

  final String? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failed = ref
        .watch(downloadTaskUpdatesProvider)
        .failed(
          ref.watch(downloadGroupProvider),
        );
    final config = ref.watchConfig;

    return ref.watch(downloadFilterProvider(filter)) == DownloadFilter.failed &&
            failed.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: () {
                for (final task in failed) {
                  final dt = castOrNull<DownloadTask>(task.task);

                  if (dt == null) continue;
                  //FIXME: need to centralize the headers injection
                  ref.invalidate(cachedBypassDdosHeadersProvider);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) {
                      final headers = ref.read(
                        httpHeadersProvider(config.auth),
                      );

                      FileDownloader().retryTask(
                        dt,
                        headers: headers,
                      );
                    },
                  );
                }
              },
              child: Text(context.t.download.retry_all),
            ),
          )
        : const SizedBox.shrink();
  }
}
