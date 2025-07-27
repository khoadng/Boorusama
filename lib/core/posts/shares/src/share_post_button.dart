// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../boorus/engine/engine.dart';
import '../../../configs/config/types.dart';
import '../../../configs/ref.dart';
import '../../post/post.dart';
import 'post_modal_share.dart';
import 'post_share_notifier.dart';
import 'post_share_state.dart';

class SharePostButton extends ConsumerWidget {
  const SharePostButton({
    required this.post,
    required this.auth,
    super.key,
  });

  final Post post;
  final BooruConfigAuth auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      splashRadius: 16,
      onPressed: () => ref.sharePost(
        post,
        context: context,
        state: ref.watch(postShareProvider((auth, post))),
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
      post: post,
      imageData: () => (
        imageUrl: defaultPostImageUrlBuilder(
          this,
          readConfigAuth,
          readConfigViewer,
        )(post),
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
