// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tag_filter_category.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/e621/feats/posts/e621_post_provider.dart';
import 'package:boorusama/boorus/e621/widgets/e621_infinite_post_list.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';

class E621TagDetailPage extends ConsumerStatefulWidget {
  const E621TagDetailPage({
    super.key,
    required this.tagName,
    required this.otherNamesBuilder,
    this.includeHeaders = true,
  });

  final String tagName;
  final Widget Function(BuildContext context) otherNamesBuilder;
  final bool includeHeaders;

  @override
  ConsumerState<E621TagDetailPage> createState() => _TagDetailPageState();
}

class _TagDetailPageState extends ConsumerState<E621TagDetailPage> {
  final selectedCategory = ValueNotifier(TagFilterCategory.newest);

  @override
  Widget build(BuildContext context) {
    return PostScope(
      fetcher: (page) => ref.read(e621PostRepoProvider).getPosts(
            queryFromTagFilterCategory(
              category: selectedCategory.value,
              tag: widget.tagName,
              builder: tagFilterCategoryToString,
            ),
            page,
          ),
      builder: (context, controller, errors) => E621InfinitePostList(
        errors: errors,
        controller: controller,
        sliverHeaderBuilder: (context) => [
          if (widget.includeHeaders)
            SliverAppBar(
              floating: true,
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: context.theme.scaffoldBackgroundColor,
              actions: [
                IconButton(
                  onPressed: () {
                    goToBulkDownloadPage(
                      context,
                      [widget.tagName],
                      ref: ref,
                    );
                  },
                  icon: const Icon(Icons.download),
                ),
              ],
            ),
          if (widget.includeHeaders)
            SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TagTitleName(tagName: widget.tagName),
                  widget.otherNamesBuilder(context),
                ],
              ),
            ),
          if (widget.includeHeaders)
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 10),
            sliver: SliverToBoxAdapter(
              child: CategoryToggleSwitch(
                onToggle: (category) {
                  selectedCategory.value = category;
                  controller.refresh();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Option<String> tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? const Some('order:score') : none();
