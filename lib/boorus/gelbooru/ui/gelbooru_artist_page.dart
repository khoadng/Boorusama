// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/application/gelbooru_artist_character_post_cubit.dart';
import 'package:boorusama/boorus/gelbooru/ui/gelbooru_infinite_post_list.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/tags.dart';
import 'package:boorusama/core/ui/tags/category_toggle_switch.dart';

class GelbooruArtistPage extends StatelessWidget
    with GelbooruArtistCharacterPostCubitMixin {
  const GelbooruArtistPage({
    super.key,
    required this.tagName,
    this.includeHeaders = true,
  });

  final String tagName;
  final bool includeHeaders;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GelbooruArtistCharacterPostCubit,
        GelbooruArtistCharacterPostState>(
      builder: (context, state) {
        return GelbooruInfinitePostList(
          refreshing: state.refreshing,
          loading: state.loading,
          hasMore: state.hasMore,
          error: state.error,
          data: state.data,
          onLoadMore: () => fetch(context),
          onRefresh: () => refresh(context),
          sliverHeaderBuilder: (context) => [
            if (includeHeaders)
              SliverAppBar(
                floating: true,
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                actions: [
                  IconButton(
                    onPressed: () {
                      goToBulkDownloadPage(
                        context,
                        [tagName],
                      );
                    },
                    icon: const Icon(Icons.download),
                  ),
                ],
              ),
            if (includeHeaders)
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TagTitleName(tagName: tagName),
                  ],
                ),
              ),
            if (includeHeaders)
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 10),
              sliver: SliverToBoxAdapter(
                child: CategoryToggleSwitch(
                  onToggle: (category) => changeCategory(context, category),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
