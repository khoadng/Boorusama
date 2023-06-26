// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/pages/search/generic_search_page.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar_result_view.dart';
import 'package:boorusama/boorus/core/pages/search/search_divider.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/result_header.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts.dart';
import 'package:boorusama/flutter.dart';

class GelbooruSearchPage extends ConsumerStatefulWidget {
  const GelbooruSearchPage({
    super.key,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final Color metatagHighlightColor;
  final String? initialQuery;

  static Route<T> routeOf<T>(
    WidgetRef ref,
    BuildContext context, {
    String? tag,
  }) {
    return PageTransition(
      type: PageTransitionType.fade,
      child: GelbooruProvider(
        builder: (gcontext) {
          return CustomContextMenuOverlay(
            child: ProviderScope(
              overrides: [
                selectedTagsProvider.overrideWith(SelectedTagsNotifier.new)
              ],
              child: GelbooruSearchPage(
                metatagHighlightColor: context.colorScheme.primary,
                initialQuery: tag,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  ConsumerState<GelbooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<GelbooruSearchPage> {
  late final queryEditingController = RichTextController(
    patternMatchMap: {
      RegExp(''): const TextStyle(color: Colors.white),
    },
    // ignore: no-empty-block
    onMatch: (match) {},
  );
  final focus = FocusNode();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null) {
        ref
            .read(postCountStateProvider.notifier)
            .getPostCount([widget.initialQuery!]);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    queryEditingController.dispose();
    focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booru = ref.watch(currentBooruProvider);

    return GenericSearchPage(
      initialQuery: widget.initialQuery,
      optionsPageBuilder: () => DefaultSearchOptionsView(
        focus: focus,
        queryEditingController: queryEditingController,
        onSearch: () {
          final tags = ref.read(selectedTagsProvider);
          final rawTags = tags.map((e) => e.toString()).toList();
          ref.read(postCountStateProvider.notifier).getPostCount(rawTags);
        },
      ),
      resultPageBuilder: (selectedTags) => PostScope(
        fetcher: (page) => ref.watch(postRepoProvider).getPostsFromTags(
              selectedTags.join(' '),
              page,
            ),
        builder: (context, controller, errors) => GelbooruInfinitePostList(
          errors: errors,
          controller: controller,
          sliverHeaderBuilder: (context) => [
            const SearchAppBarResultView(),
            const SliverToBoxAdapter(child: SelectedTagListWithData()),
            const SliverToBoxAdapter(child: SearchDivider(height: 7)),
            SliverToBoxAdapter(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (booru.booruType == BooruType.gelbooru)
                    ResultHeaderWithProvider(selectedTags: selectedTags),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: PostGridConfigIconButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
