// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';

class FavoritesPage extends StatelessWidget
    with DanbooruPostCubitStatelessMixin {
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
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => DanbooruPostCubit.of(
                    dContext,
                    extra: DanbooruPostExtra(tag: 'ordfav:$username'),
                  )..refresh(),
                ),
              ],
              child: CustomContextMenuOverlay(
                child: FavoritesPage(username: username),
              ),
            );
          },
        );
      },
    );
  }

  final String username;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DanbooruPostCubit, DanbooruPostState>(
      builder: (context, state) {
        return DanbooruInfinitePostList(
          refreshing: state.refreshing,
          loading: state.loading,
          hasMore: state.hasMore,
          error: state.error,
          data: state.data,
          onLoadMore: () => fetch(context),
          onRefresh: () {
            refresh(context);
          },
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
      },
    );
  }
}
