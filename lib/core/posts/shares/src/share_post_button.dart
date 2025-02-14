// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../boorus/engine/engine.dart';
import '../../../foundation/display.dart';
import '../../post/post.dart';
import 'post_modal_share.dart';
import 'post_share_notifier.dart';
import 'post_share_state.dart';

class SharePostButton extends ConsumerWidget {
  const SharePostButton({
    required this.post,
    super.key,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      splashRadius: 16,
      onPressed: () => ref.sharePost(
        post,
        context: context,
        state: ref.watch(postShareProvider(post)),
      ),
      icon: const Icon(
        Symbols.share,
      ),
    );
  }
}

extension PostShareX on WidgetRef {
  void sharePost(
    Post post, {
    required BuildContext context,
    required PostShareState state,
  }) {
    final modal = PostModalShare(
      booruLink: state.booruLink,
      sourceLink: state.sourceLink,
      imageData: () => (
        imageUrl: defaultPostImageUrlBuilder(this)(post),
        imageExt: post.format,
      ),
    );

    const routeSettings = RouteSettings(
      name: 'post_share',
    );

    Screen.of(context).size == ScreenSize.small
        ? showModalBottomSheet(
            context: context,
            routeSettings: routeSettings,
            builder: (context) => modal,
          )
        : showDialog(
            context: context,
            routeSettings: routeSettings,
            builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: modal,
            ),
          );
  }
}
