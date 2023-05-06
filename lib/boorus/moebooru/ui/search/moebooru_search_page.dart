// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/utils.dart';
import 'package:boorusama/boorus/moebooru/ui/posts.dart';
import 'package:boorusama/core/application/search/search_notifier.dart';
import 'package:boorusama/core/application/search/search_provider.dart';
import 'package:boorusama/core/application/search/selected_tags_notifier.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/ui/post_grid_config_icon_button.dart';
import 'package:boorusama/core/ui/posts/post_scope.dart';
import 'package:boorusama/core/ui/search/search_bar_with_data.dart';
import 'package:boorusama/core/ui/search/search_button.dart';
import 'package:boorusama/core/ui/search/search_divider.dart';
import 'package:boorusama/core/ui/search/search_landing_view.dart';
import 'package:boorusama/core/ui/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/ui/search/tag_suggestion_items.dart';

class MoebooruSearchPage extends ConsumerStatefulWidget {
  const MoebooruSearchPage({
    super.key,
    required this.metatags,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final List<Metatag> metatags;
  final Color metatagHighlightColor;
  final String? initialQuery;

  @override
  ConsumerState<MoebooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<MoebooruSearchPage> {
  late final _tags = widget.metatags.map((e) => e.name).join('|');
  late final queryEditingController = RichTextController(
    patternMatchMap: {
      RegExp('($_tags)+:'): TextStyle(
        fontWeight: FontWeight.w800,
        color: widget.metatagHighlightColor,
      ),
    },
    // ignore: no-empty-block
    onMatch: (List<String> match) {},
  );
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null) {
        ref
            .read(searchProvider.notifier)
            .skipToResultWithTag(widget.initialQuery!);
      }
    });
  }

  @override
  void dispose() {
    queryEditingController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayState = ref.watch(searchProvider);
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    ref.listen(
      sanitizedQueryProvider,
      (prev, curr) {
        if (prev != curr) {
          final displayState = ref.read(searchProvider);
          if (curr.isEmpty && displayState != DisplayState.result) {
            queryEditingController.clear();
          }
        }
      },
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Builder(builder: (context) {
        switch (displayState) {
          case DisplayState.options:
            return Scaffold(
              floatingActionButton: const SearchButton(),
              appBar: _AppBar(
                focusNode: focus,
                queryEditingController: queryEditingController,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      SelectedTagListWithData(),
                      SearchDivider(),
                      SearchLandingView(),
                    ],
                  ),
                ),
              ),
            );
          case DisplayState.suggestion:
            return Scaffold(
              appBar: _AppBar(
                focusNode: focus,
                queryEditingController: queryEditingController,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    const SelectedTagListWithData(),
                    const SearchDivider(),
                    Expanded(
                      child: TagSuggestionItemsWithData(
                        textColorBuilder: (tag) =>
                            generateDanbooruAutocompleteTagColor(tag, theme),
                      ),
                    ),
                  ],
                ),
              ),
            );
          case DisplayState.result:
            final selectedTags = ref.watch(selectedRawTagStringProvider);

            return PostScope(
              fetcher: (page) =>
                  context.read<PostRepository>().getPostsFromTags(
                        selectedTags.join(' '),
                        page,
                      ),
              builder: (context, controller, errors) =>
                  MoebooruInfinitePostList(
                errors: errors,
                controller: controller,
                sliverHeaderBuilder: (context) => [
                  SliverAppBar(
                    titleSpacing: 0,
                    toolbarHeight: kToolbarHeight * 1.9,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    title: SizedBox(
                      height: kToolbarHeight * 1.85,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SearchBarResulView(),
                          ),
                          SizedBox(height: 10),
                          SelectedTagListWithData(),
                        ],
                      ),
                    ),
                    floating: true,
                    snap: true,
                    automaticallyImplyLeading: false,
                  ),
                  const SliverToBoxAdapter(child: SearchDivider(height: 7)),
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: PostGridConfigIconButton(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
        }
      }),
    );
  }
}

// ignore: prefer_mixin
class _AppBar extends StatelessWidget with PreferredSizeWidget {
  const _AppBar({
    required this.queryEditingController,
    this.focusNode,
  });

  final RichTextController queryEditingController;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight * 1.2,
      title: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return SearchBarWithData(
            autofocus: state.settings.autoFocusSearchBar,
            focusNode: focusNode,
            queryEditingController: queryEditingController,
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.2);
}
