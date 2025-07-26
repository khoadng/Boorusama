// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/widgets/adaptive_button_row.dart';
import '../favorites/providers.dart';
import '../favorites/widgets.dart';
import 'types.dart';

class HydrusPostActionToolbar extends ConsumerWidget {
  const HydrusPostActionToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<HydrusPost>(context);
    final canFav = ref
        .watch(hydrusCanFavoriteProvider(ref.watchConfigAuth))
        .maybeWhen(
          data: (fav) => fav,
          orElse: () => false,
        );
    final controller = PostDetails.of<HydrusPost>(context).pageViewController;

    return CommonPostButtonsBuilder(
      post: post,
      onStartSlideshow: controller.startSlideshow,
      builder: (context, buttons) {
        return SliverToBoxAdapter(
          child: AdaptiveButtonRow.menu(
            buttonWidth: 52,
            buttons: [
              if (canFav)
                ButtonData(
                  behavior: ButtonBehavior.alwaysVisible,
                  widget: HydrusFavoritePostButton(post: post),
                  title: context.t.post.action.favorite,
                ),
              ButtonData(
                behavior: ButtonBehavior.alwaysVisible,
                widget: BookmarkPostButton(post: post),
                title: context.t.post.action.bookmark,
              ),
              ButtonData(
                behavior: ButtonBehavior.alwaysVisible,
                widget: DownloadPostButton(post: post),
                title: context.t.download.download,
              ),
              ...buttons,
            ],
          ),
        );
      },
    );
  }
}
