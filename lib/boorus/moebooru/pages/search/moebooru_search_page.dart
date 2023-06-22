// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/pages/search/generic_search_page.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar_result_view.dart';
import 'package:boorusama/boorus/core/pages/search/search_divider.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/boorus/moebooru/pages/posts.dart';
import 'package:boorusama/flutter.dart';

class MoebooruSearchPage extends ConsumerStatefulWidget {
  const MoebooruSearchPage({
    super.key,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final Color metatagHighlightColor;
  final String? initialQuery;

  static Route<T> routeOf<T>(
    BuildContext context,
    WidgetRef ref, {
    String? tag,
  }) {
    return PageTransition(
      type: PageTransitionType.fade,
      child: MoebooruProvider(
        builder: (gcontext) {
          return CustomContextMenuOverlay(
            child: ProviderScope(
              overrides: [
                selectedTagsProvider.overrideWith(SelectedTagsNotifier.new),
              ],
              child: MoebooruSearchPage(
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
  ConsumerState<MoebooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<MoebooruSearchPage> {
  @override
  Widget build(BuildContext context) {
    return GenericSearchPage(
      initialQuery: widget.initialQuery,
      resultPageBuilder: (selectedTags) => PostScope(
        fetcher: (page) => ref.watch(postRepoProvider).getPostsFromTags(
              selectedTags.join(' '),
              page,
            ),
        builder: (context, controller, errors) => MoebooruInfinitePostList(
          errors: errors,
          controller: controller,
          sliverHeaderBuilder: (context) => [
            const SearchAppBarResultView(),
            const SliverToBoxAdapter(child: SelectedTagListWithData()),
            const SliverToBoxAdapter(child: SearchDivider(height: 7)),
            const SliverToBoxAdapter(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
      ),
    );
  }
}
