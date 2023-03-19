// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infra/local/repositories/metatags/user_metatag_repository.dart';
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/boorus/gelbooru/ui/gelbooru_metatags_section.dart';
import 'package:boorusama/core/application/search_history/search_history.dart';
import 'package:boorusama/core/application/tags/tags.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/search/search_landing_view.dart';
import 'package:boorusama/core/ui/search_bar.dart';

class GelbooruSearchPage extends StatefulWidget {
  const GelbooruSearchPage({
    super.key,
    required this.metatags,
    required this.metatagHighlightColor,
    this.autoFocusSearchBar = true,
    required this.userMetatagRepository,
  });

  final List<Metatag> metatags;
  final Color metatagHighlightColor;
  final bool autoFocusSearchBar;
  final UserMetatagRepository userMetatagRepository;

  @override
  State<GelbooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<GelbooruSearchPage> {
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
  final compositeSubscription = CompositeSubscription();
  final focus = FocusNode();

  @override
  void dispose() {
    compositeSubscription.dispose();
    queryEditingController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildSearchBar(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchLandingView(
              onAddTagRequest: () => goToGelbooruQuickSearchPage(
                context,
                onSubmitted: (context, text) {
                  Navigator.of(context).pop();
                  context
                      .read<FavoriteTagBloc>()
                      .add(FavoriteTagAdded(tag: text));
                },
                onSelected: (context, tag) => context
                    .read<FavoriteTagBloc>()
                    .add(FavoriteTagAdded(tag: tag.value)),
              ),
              onHistoryTap: (value) => queryEditingController.text = value,
              onTagTap: (value) => queryEditingController.text = value,
              onHistoryRemoved: (value) => context
                  .read<SearchHistoryBloc>()
                  .add(SearchHistoryRemoved(value.query)),
              onHistoryCleared: () => context
                  .read<SearchHistoryBloc>()
                  .add(const SearchHistoryCleared()),
              onFullHistoryRequested: () => goToSearchHistoryPage(
                context,
                onClear: () => context
                    .read<SearchHistoryBloc>()
                    .add(const SearchHistoryCleared()),
                onRemove: (history) => context
                    .read<SearchHistoryBloc>()
                    .add(SearchHistoryRemoved(history.query)),
                onTap: (value) => queryEditingController.text = value,
              ),
              metatagsBuilder: (context) => GelbooruMetatagsSection(
                metatags: widget.metatags,
                userMetatagRepository: widget.userMetatagRepository,
                cheatsheetUrl:
                    'https://gelbooru.com/index.php?page=wiki&s=&s=view&id=26263',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
  ) {
    return SearchBar(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back,
        ),
      ),
      queryEditingController: queryEditingController,
      autofocus: true,
      trailing: IconButton(
        onPressed: () {
          queryEditingController.clear();
        },
        icon: const Icon(Icons.close),
      ),
      onChanged: (value) => print(value),
      onSubmitted: (value) {
        print(value);
      },
      // hintText: 'pool.search.hint'.tr(),
      // onTap: () => searchBloc.add(const PoolSearchResumed()),
    );
  }
}
