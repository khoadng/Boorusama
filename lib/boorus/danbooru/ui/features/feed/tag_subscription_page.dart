import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class TagSubscriptionPage extends StatefulWidget {
  const TagSubscriptionPage({
    super.key,
  });

  @override
  State<TagSubscriptionPage> createState() => _TagSubscriptionPageState();
}

class _TagSubscriptionPageState extends State<TagSubscriptionPage> {
  final _selectedTag = ValueNotifier('search:artists');
  final _selectedTagStream = BehaviorSubject<String>();
  final _compositeSubscription = CompositeSubscription();
  final searches = [
    'search:artists',
    'search:characters',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTag.addListener(() => _selectedTagStream.add(_selectedTag.value));

    _selectedTagStream
        .debounceTime(const Duration(milliseconds: 350))
        .distinct()
        .listen(_sendRefresh)
        .addTo(_compositeSubscription);
  }

  @override
  void dispose() {
    _compositeSubscription.dispose();
    _selectedTagStream.close();
    _selectedTag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          return InfiniteLoadListScrollView(
            extendBody: Screen.of(context).size == ScreenSize.small,
            enableLoadMore: state.hasMore,
            onRefresh: (controller) {
              _sendRefresh(_selectedTag.value);
              Future.delayed(
                const Duration(seconds: 1),
                () => controller.refreshCompleted(),
              );
            },
            onLoadMore: () => context.read<PostBloc>().add(PostFetched(
                  tags: _selectedTag.value,
                  fetcher: SearchedPostFetcher.fromTags(_selectedTag.value),
                )),
            sliverBuilder: (controller) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ValueListenableBuilder<String>(
                    valueListenable: _selectedTag,
                    builder: (context, selectedTag, child) => Container(
                      margin: const EdgeInsets.only(left: 8),
                      height: 50,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          final selected = selectedTag == searches[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              disabledColor:
                                  Theme.of(context).chipTheme.disabledColor,
                              backgroundColor:
                                  Theme.of(context).chipTheme.backgroundColor,
                              selectedColor:
                                  Theme.of(context).chipTheme.selectedColor,
                              selected: selected,
                              onSelected: (selected) => selected
                                  ? _selectedTag.value = searches[index]
                                  : _selectedTag.value = '',
                              padding: const EdgeInsets.all(4),
                              labelPadding: const EdgeInsets.all(1),
                              visualDensity: VisualDensity.compact,
                              side: BorderSide(
                                width: 0.5,
                                color: Theme.of(context).hintColor,
                              ),
                              label: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.85,
                                ),
                                child: Text(
                                  searches[index]
                                      // .keyword
                                      .removeUnderscoreWithSpace(),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              HomePostGrid(controller: controller),
            ],
            isLoading: state.loading,
          );
        },
      ),
    );
  }

  void _sendRefresh(String tag) => context.read<PostBloc>().add(PostRefreshed(
        tag: tag,
        fetcher: SearchedPostFetcher.fromTags(tag),
      ));
}
