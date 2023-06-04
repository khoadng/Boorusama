// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/features/posts/app.dart';
import 'package:boorusama/boorus/danbooru/pages/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'most_search_tag_list.dart';

class LatestView extends ConsumerStatefulWidget {
  const LatestView({
    super.key,
    this.onMenuTap,
    this.useAppBarPadding,
  });

  final VoidCallback? onMenuTap;
  final bool? useAppBarPadding;

  @override
  ConsumerState<LatestView> createState() => _LatestViewState();
}

class _LatestViewState extends ConsumerState<LatestView> {
  final _autoScrollController = AutoScrollController();
  final _selectedTag = ValueNotifier('');

  @override
  void dispose() {
    _autoScrollController.dispose();
    _selectedTag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DanbooruPostScope(
      fetcher: (page) =>
          ref.read(danbooruPostRepoProvider).getPosts(_selectedTag.value, page),
      builder: (context, controller, errors) => DanbooruInfinitePostList(
        errors: errors,
        controller: controller,
        scrollController: _autoScrollController,
        sliverHeaderBuilder: (context) => [
          _AppBar(
            onMenuTap: widget.onMenuTap,
            primary: widget.useAppBarPadding,
          ),
          SliverToBoxAdapter(
            child: ValueListenableBuilder<String>(
              valueListenable: _selectedTag,
              builder: (context, value, child) => _MostSearchTagSection(
                selected: value,
                onSelected: (search) {
                  _selectedTag.value =
                      search.keyword == value ? '' : search.keyword;
                  controller.refresh();
                  _autoScrollController.jumpTo(0);
                },
              ),
            ),
          ),
        ],
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
    return MostSearchTagList(
      onSelected: onSelected,
      selected: selected,
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.onMenuTap,
    this.primary,
  });

  final VoidCallback? onMenuTap;
  final bool? primary;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      toolbarHeight: kToolbarHeight * 1.2,
      primary: primary ?? true,
      title: BooruSearchBar(
        enabled: false,
        leading: onMenuTap != null
            ? IconButton(
                splashRadius: 16,
                icon: const Icon(Icons.menu),
                onPressed: () => onMenuTap!(),
              )
            : null,
        onTap: () => goToSearchPage(context),
      ),
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
    );
  }
}
