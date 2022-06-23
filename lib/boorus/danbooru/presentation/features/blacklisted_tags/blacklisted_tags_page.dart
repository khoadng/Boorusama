// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/user/user.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/autocomplete/autocomplete_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/tag_info_service.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class BlacklistedTagsSearchPage extends StatefulWidget {
  const BlacklistedTagsSearchPage({
    Key? key,
    required this.onSelectedDone,
  }) : super(key: key);

  final void Function(List<TagSearchItem> tags) onSelectedDone;

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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => AppRouter.router.pop(context),
              ),
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
                      margin: const EdgeInsets.only(left: 8),
                      height: 35,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: state.selectedTags.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildSelectedTagChip(
                                state.selectedTags[index]),
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

  Widget _buildSelectedTagChip(TagSearchItem tagSearchItem) {
    if (tagSearchItem.operator == FilterOperator.none) {
      return Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: Colors.grey[800],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          deleteIcon: const Icon(
            FontAwesomeIcons.xmark,
            color: Colors.red,
            size: 15,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          onDeleted: () => context
              .read<TagSearchBloc>()
              .add(TagSearchSelectedTagRemoved(tagSearchItem)),
          label: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85),
            child: Text(
              tagSearchItem.tag,
              overflow: TextOverflow.fade,
            ),
          ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          labelPadding: const EdgeInsets.symmetric(horizontal: 1),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
          label: Text(
            filterOperatorToStringCharacter(tagSearchItem.operator),
          ),
        ),
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: Colors.grey[800],
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8))),
          deleteIcon: const Icon(
            FontAwesomeIcons.xmark,
            color: Colors.red,
            size: 15,
          ),
          onDeleted: () => context
              .read<TagSearchBloc>()
              .add(TagSearchSelectedTagRemoved(tagSearchItem)),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          label: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85),
            child: Text(
              tagSearchItem.tag,
              overflow: TextOverflow.fade,
            ),
          ),
        )
      ],
    );
  }
}

String filterOperatorToStringCharacter(FilterOperator operator) {
  switch (operator) {
    case FilterOperator.not:
      return 'not'.toUpperCase();
    case FilterOperator.or:
      return 'or'.toUpperCase();
    default:
      return '';
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
        title: const Text('Blacklisted tags'),
      ),
      body: SafeArea(
        child: BlocConsumer<UserBlacklistedTagsBloc, UserBlacklistedTagsState>(
          listenWhen: (previous, current) =>
              current is UserBlacklistedTagsError,
          listener: (context, state) {
            final snackbar = SnackBar(
              behavior: SnackBarBehavior.floating,
              elevation: 6,
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
                    padding: const EdgeInsets.all(16),
                    child: OpenContainer(
                      closedColor: Colors.transparent,
                      closedElevation: 0,
                      openElevation: 0,
                      closedBuilder: (context, action) => ElevatedButton(
                          onPressed: () => action.call(),
                          child: const Text('Add tag(s)')),
                      openColor: Colors.transparent,
                      openBuilder: (context, action) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                              create: (context) => TagSearchBloc(
                                  tagInfo: context.read<TagInfo>(),
                                  autocompleteRepository:
                                      context.read<AutocompleteRepository>())),
                        ],
                        child: BlacklistedTagsSearchPage(
                          onSelectedDone: (tagItems) =>
                              bloc.add(UserEventBlacklistedTagChanged(
                            tags: [
                              ...state.blacklistedTags,
                              tagItems.map((e) => e.toString()).join(' '),
                            ],
                            userId: userId,
                          )),
                        ),
                      ),
                    ),
                  )),
                  SliverToBoxAdapter(
                    child: WarningContainer(contentBuilder: (context) {
                      return RichText(
                          text: const TextSpan(children: [
                        TextSpan(text: 'Only support '),
                        TextSpan(
                            text: 'NOT ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'operator and '),
                        TextSpan(
                            text: 'OR ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'operator.'),
                        TextSpan(
                            text:
                                "\n\nBlacklisting using metatags won't work for current version."),
                      ]));
                    }),
                  ),
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
                child: Text('Failed to load blacklisted tags'),
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
