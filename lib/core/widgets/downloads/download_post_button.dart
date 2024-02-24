// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';

class DownloadPostButton extends ConsumerWidget {
  const DownloadPostButton({
    super.key,
    required this.post,
    this.small = false,
  });

  final Post post;
  final bool small;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DownloadProviderWidget(
      builder: (context, download) => !small
          ? IconButton(
              splashRadius: 16,
              onPressed: () {
                showDownloadStartToast(context);
                download(post);
              },
              icon: const Icon(
                Symbols.download,
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  showDownloadStartToast(context);
                  download(post);
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
