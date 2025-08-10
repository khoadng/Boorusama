// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../../post/post.dart';
import 'share.dart';

class SharePostButton extends ConsumerWidget {
  const SharePostButton({
    required this.post,
    required this.auth,
    required this.configViewer,
    super.key,
  });

  final Post post;
  final BooruConfigAuth auth;
  final BooruConfigViewer configViewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      splashRadius: 16,
      onPressed: () => ref
          .read(shareProvider)
          .sharePost(
            post,
            auth,
            context: context,
            configViewer: configViewer,
          ),
      icon: const Icon(Symbols.share),
    );
  }
}
