// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({
    super.key,
    required this.username,
  });

  static Widget of(
    BuildContext context, {
    required String username,
  }) {
    return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return DanbooruProvider.of(
          context,
          booru: state.booru!,
          builder: (dContext) {
            return CustomContextMenuOverlay(
              child: FavoritesPage(username: username),
            );
          },
        );
      },
    );
  }

  final String username;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with DanbooruPostTransformMixin, DanbooruPostServiceProviderMixin {
  late final controller = PostGridController<DanbooruPost>(
      fetcher: (page) => context
          .read<DanbooruPostRepository>()
          .getPosts('ordfav:${widget.username}', page)
          .run()
          .then((value) => value.fold(
                (l) => <DanbooruPost>[],
                (r) => r,
              ))
          .then(transform),
      refresher: () => context
          .read<DanbooruPostRepository>()
          .getPosts('ordfav:${widget.username}', 1)
          .run()
          .then((value) => value.fold(
                (l) => <DanbooruPost>[],
                (r) => r,
              ))
          .then(transform));

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DanbooruInfinitePostList(
      controller: controller,
      sliverHeaderBuilder: (context) => [
        SliverAppBar(
          title: const Text('profile.favorites').tr(),
          floating: true,
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 5,
          ),
        ),
      ],
    );
  }
}
