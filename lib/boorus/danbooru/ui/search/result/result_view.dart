// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts/post_count_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/ui/post_grid_config_icon_button.dart';
import 'package:boorusama/functional.dart';
import 'related_tag_section.dart';
import 'result_header.dart';

class ResultView extends StatefulWidget {
  const ResultView({
    super.key,
    this.headerBuilder,
    this.scrollController,
    this.backgroundColor,
  });

  final List<Widget> Function()? headerBuilder;
  final AutoScrollController? scrollController;
  final Color? backgroundColor;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final refreshController = RefreshController();
  late final scrollController =
      widget.scrollController ?? AutoScrollController();

  @override
  void dispose() {
    refreshController.dispose();
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagSearchBloc, TagSearchState>(
      builder: (context, state) => BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return DanbooruPostScope(
            fetcher: (page) => context.read<DanbooruPostRepository>().getPosts(
                  state.selectedTags.join(' '),
                  page,
                ),
            builder: (context, controller, errors) {
              return DanbooruInfinitePostList(
                controller: controller,
                errors: errors,
                sliverHeaderBuilder: (context) => [
                  ...widget.headerBuilder?.call() ?? [],
                  const SliverToBoxAdapter(child: RelatedTagSection()),
                  SliverToBoxAdapter(
                      child: Row(
                    children: [
                      BlocBuilder<PostCountCubit, PostCountState>(
                        builder: (context, postCountState) {
                          final tags = state.selectedTags
                              .map((e) => e.toString())
                              .toList();
                          if (postCountState.isLoading(tags)) {
                            return const ResultHeader(count: 0, loading: true);
                          } else if (postCountState.isEmpty(tags)) {
                            return const SizedBox.shrink();
                          } else {
                            return postCountState
                                .getPostCount(tags)
                                .toOption()
                                .fold(
                                  () => const SizedBox.shrink(),
                                  (count) => ResultHeader(
                                    count: count,
                                    loading: false,
                                  ),
                                );
                          }
                        },
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: PostGridConfigIconButton(),
                      ),
                    ],
                  )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class NoImplicitScrollPhysics extends AlwaysScrollableScrollPhysics {
  const NoImplicitScrollPhysics({super.parent});

  @override
  bool get allowImplicitScrolling => false;

  @override
  NoImplicitScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoImplicitScrollPhysics(parent: buildParent(ancestor));
  }
}
