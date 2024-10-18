// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/display.dart';

class SharePostButton extends ConsumerWidget {
  const SharePostButton({
    super.key,
    required this.post,
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

    Screen.of(context).size == ScreenSize.small
        ? showMaterialModalBottomSheet(
            context: context,
            barrierColor: Colors.black45,
            backgroundColor: Colors.transparent,
            builder: (context) => modal,
          )
        : showDialog(
            context: context,
            builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: modal,
            ),
          );
  }
}
