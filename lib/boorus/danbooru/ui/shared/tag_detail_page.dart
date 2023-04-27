// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/tags.dart';

class TagDetailPage extends StatelessWidget
    with DanbooruArtistCharacterPostCubitMixin {
  const TagDetailPage({
    super.key,
    required this.tagName,
    required this.otherNamesBuilder,
    required this.backgroundImageUrl,
    this.includeHeaders = true,
  });

  final String tagName;
  final String backgroundImageUrl;
  final Widget Function(BuildContext context) otherNamesBuilder;
  final bool includeHeaders;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DanbooruArtistCharacterPostCubit,
        DanbooruArtistCharacterPostState>(
      builder: (context, state) {
        return DanbooruInfinitePostList(
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
                    otherNamesBuilder(context),
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
