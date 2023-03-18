// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/tag/trending_tag_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/infinite_post_list.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/common.dart';
import 'most_search_tag_list.dart';

class LatestViewDesktop extends StatefulWidget {
  const LatestViewDesktop({
    super.key,
  });

  @override
  State<LatestViewDesktop> createState() => _LatestViewDesktopState();
}

class _LatestViewDesktopState extends State<LatestViewDesktop> {
  final AutoScrollController _autoScrollController = AutoScrollController();
  final ValueNotifier<String> _selectedTag = ValueNotifier('');
  final BehaviorSubject<String> _selectedTagStream = BehaviorSubject();
  final CompositeSubscription _compositeSubscription = CompositeSubscription();

  void _sendRefresh(String tag) {
    _autoScrollController.jumpTo(0);
    context.read<PostBloc>().add(PostRefreshed(
          tag: tag,
          fetcher: SearchedPostFetcher.fromTags(tag),
        ));
  }

  @override
  void initState() {
    super.initState();
    _selectedTag.addListener(() => _selectedTagStream.add(_selectedTag.value));

    _selectedTagStream
        .debounceTime(const Duration(milliseconds: 250))
        .distinct()
        .listen((tag) {
      _sendRefresh(tag);
    }).addTo(_compositeSubscription);
  }

  @override
  void dispose() {
    _autoScrollController.dispose();
    _compositeSubscription.dispose();
    _selectedTagStream.close();
    _selectedTag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              const Spacer(),
              ButtonBar(
                buttonPadding: EdgeInsets.zero,
                children: [
                  _ToolbarButton(
                    onPressed: () => goToSearchPage(context),
                    child: const Icon(Icons.search),
                  ),
                  _ToolbarButton(
                    onPressed: () => _sendRefresh(_selectedTag.value),
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(
          height: 8,
          thickness: 2,
        ),
        ValueListenableBuilder<String>(
          valueListenable: _selectedTag,
          builder: (context, value, child) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _MostSearchTagSection(
              selected: value,
              onSelected: (search) {
                _selectedTag.value =
                    search.keyword == value ? '' : search.keyword;
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InfinitePostList(
              scrollController: _autoScrollController,
              onLoadMore: () => context.read<PostBloc>().add(PostFetched(
                    tags: _selectedTag.value,
                    fetcher: SearchedPostFetcher.fromTags(_selectedTag.value),
                  )),
              onRefresh: (controller) {
                _sendRefresh(_selectedTag.value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: MaterialButton(
        minWidth: 0,
        color: Theme.of(context).cardColor,
        shape: const CircleBorder(),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: child,
        ),
      ),
    );
  }
}

class _MostSearchTagSection extends StatelessWidget {
  const _MostSearchTagSection({
    required this.onSelected,
    required this.selected,
  });

  final void Function(Search search) onSelected;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final status =
        context.select((TrendingTagCubit cubit) => cubit.state.status);

    switch (status) {
      case LoadStatus.success:
        return MostSearchTagList(
          onSelected: onSelected,
          selected: selected,
        );
      case LoadStatus.failure:
        return const SizedBox.shrink();
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const TagChipsPlaceholder();
    }
  }
}
