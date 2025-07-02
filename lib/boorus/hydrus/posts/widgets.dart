// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/widgets.dart';
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
    final canFav =
        ref.watch(hydrusCanFavoriteProvider(ref.watchConfigAuth)).maybeWhen(
              data: (fav) => fav,
              orElse: () => false,
            );

    return SliverToBoxAdapter(
      child: PostActionToolbar(
        children: [
          if (canFav) HydrusFavoritePostButton(post: post),
          BookmarkPostButton(post: post),
          DownloadPostButton(post: post),
        ],
      ),
    );
  }
}
