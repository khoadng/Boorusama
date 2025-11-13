// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../configs/config/providers.dart';
import '../../../../downloads/downloader/providers.dart';
import '../../../../widgets/booru_tooltip.dart';
import '../../../post/types.dart';

class DownloadPostButton extends ConsumerWidget {
  const DownloadPostButton({
    required this.post,
    super.key,
    this.small = false,
  });

  final Post post;
  final bool small;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(
      downloadNotifierProvider(
        ref.watch(
          downloadNotifierParamsProvider((
            ref.watchConfigAuth,
            ref.watchConfigDownload,
          )),
        ),
      ).notifier,
    );

    return BooruTooltip(
      message: context.t.download.download,
      child: !small
          ? IconButton(
              splashRadius: 16,
              onPressed: () {
                notifier.download(post);
              },
              icon: const Icon(
                Symbols.download,
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  notifier.download(post);
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Symbols.download,
                  ),
                ),
              ),
            ),
    );
  }
}
