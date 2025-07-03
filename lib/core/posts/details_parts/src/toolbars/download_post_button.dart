// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../downloads/downloader/providers.dart';
import '../../../post/post.dart';

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
    return !small
        ? IconButton(
            splashRadius: 16,
            onPressed: () {
              ref.download(post);
            },
            icon: const Icon(
              Symbols.download,
            ),
          )
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ref.download(post);
              },
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Symbols.download,
                ),
              ),
            ),
          );
  }
}
