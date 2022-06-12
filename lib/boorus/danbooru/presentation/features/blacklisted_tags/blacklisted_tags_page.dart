// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/user/user_blacklisted_tags_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/tag_suggestion_items.dart';

class BlacklistedTagsSearchPage extends StatefulWidget {
  const BlacklistedTagsSearchPage({
    Key? key,
    required this.onSelectedDone,
  }) : super(key: key);

  final void Function(List<Tag> tags) onSelectedDone;

  @override
  State<BlacklistedTagsSearchPage> createState() =>
      _BlacklistedTagsSearchPageState();
}

class _BlacklistedTagsSearchPageState extends State<BlacklistedTagsSearchPage> {
  final queryEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    queryEditingController.addListener(() {
      queryEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: queryEditingController.text.length));
    });
  }

  @override
  void dispose() {
    queryEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TagSearchBloc, TagSearchState>(
          listenWhen: (previous, current) => current.query.isEmpty,
          listener: (context, state) => queryEditingController.clear(),
        ),
        BlocListener<TagSearchBloc, TagSearchState>(
          listenWhen: (previous, current) => current.isDone,
          listener: (context, state) {
            if (state.selectedTags.isNotEmpty) {
              widget.onSelectedDone(state.selectedTags);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              context.read<TagSearchBloc>().add(const TagSearchDone()),
          heroTag: null,
          child: const FaIcon(FontAwesomeIcons.check),
        ),
        appBar: AppBar(
          toolbarHeight: kToolbarHeight * 1.2,
          elevation: 0,
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: BlocBuilder<TagSearchBloc, TagSearchState>(
            builder: (context, state) => SearchBar(
              autofocus: true,
              queryEditingController: queryEditingController,
              trailing: state.query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context
                          .read<TagSearchBloc>()
                          .add(const TagSearchCleared()),
                    )
                  : null,
              onChanged: (value) =>
                  context.read<TagSearchBloc>().add(TagSearchChanged(value)),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<TagSearchBloc, TagSearchState>(
            builder: (context, state) {
              return Column(
                children: [
                  if (state.selectedTags.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(left: 8.0),
                      height: 50,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: state.selectedTags.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Chip(
                              padding: const EdgeInsets.all(4.0),
                              labelPadding: const EdgeInsets.all(1.0),
                              visualDensity: VisualDensity.compact,
                              deleteIcon: const Icon(
                                FontAwesomeIcons.xmark,
                                color: Colors.red,
                                size: 15,
                              ),
                              onDeleted: () => context
                                  .read<TagSearchBloc>()
                                  .add(TagSearchSelectedTagRemoved(
                                      state.selectedTags[index])),
                              label: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.85),
                                child: Text(
                                  state.selectedTags[index].rawName
                                      .replaceAll('_', ' '),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(
                      height: 15,
                      thickness: 3,
                      indent: 10,
                      endIndent: 10,
                    ),
                  ],
                  Expanded(
                    child: TagSuggestionItems(
                      tags: state.suggestionTags,
                      onItemTap: (tag) => context
                          .read<TagSearchBloc>()
                          .add(TagSearchNewTagSelected(tag)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class BlacklistedTagsPage extends StatelessWidget {
  const BlacklistedTagsPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final int userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blacklisted tags"),
      ),
      body: SafeArea(
        child: BlocConsumer<UserBlacklistedTagsBloc, UserBlacklistedTagsState>(
          listenWhen: (previous, current) =>
              current is UserBlacklistedTagsError,
          listener: (context, state) {
            final snackbar = SnackBar(
              behavior: SnackBarBehavior.floating,
              elevation: 6.0,
              content: Text((state as UserBlacklistedTagsError).errorMessage),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          },
          builder: (context, state) {
            if (state.status == LoadStatus.success ||
                state.status == LoadStatus.loading) {
              final bloc = context.read<UserBlacklistedTagsBloc>();
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                      child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OpenContainer(
                      closedColor: Colors.transparent,
                      closedBuilder: (context, action) => ElevatedButton(
                          onPressed: () => action.call(),
                          child: const Text("Add tag(s)")),
                      openColor: Colors.transparent,
                      openBuilder: (context, action) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                              create: (context) => TagSearchBloc(
                                  tagRepository:
                                      context.read<ITagRepository>())),
                        ],
                        child: BlacklistedTagsSearchPage(
                          onSelectedDone: (tags) => bloc.add(
                              UserEventBlacklistedTagChanged(tags: [
                            ...state.blacklistedTags,
                            ...tags.map((e) => e.rawName)
                          ], userId: userId)),
                        ),
                      ),
                    ),
                  )),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tag = state.blacklistedTags[index];

                        return ListTile(
                          title: Text(tag),
                          trailing: IconButton(
                              onPressed: () => context
                                  .read<UserBlacklistedTagsBloc>()
                                  .add(UserEventBlacklistedTagChanged(
                                    tags: [
                                      ...state.blacklistedTags..remove(tag)
                                    ],
                                    userId: userId,
                                  )),
                              icon: const FaIcon(FontAwesomeIcons.xmark)),
                        );
                      },
                      childCount: state.blacklistedTags.length,
                    ),
                  )
                ],
              );
            } else if (state.status == LoadStatus.failure) {
              return const Center(
                child: Text("Failed to load blacklisted tags"),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
