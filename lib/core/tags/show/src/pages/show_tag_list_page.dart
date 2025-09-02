// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/toast.dart';
import '../../../../blacklists/providers.dart';
import '../../../../configs/config.dart';
import '../../../../posts/post/post.dart';
import '../../../favorites/providers.dart';
import '../../../tag/tag.dart';
import '../providers.dart';
import '../widgets/show_tag_action_bar.dart';
import '../widgets/show_tag_list.dart';
import 'show_tag_list_page_scaffold.dart';

class ShowTagListPage extends ConsumerStatefulWidget {
  const ShowTagListPage({
    required this.post,
    required this.auth,
    required this.initiallyMultiSelectEnabled,
    super.key,
    this.onAddToBlacklist,
    this.onOpenWiki,
    this.contextMenuBuilder,
  });

  final Post post;
  final void Function(Tag tag)? onAddToBlacklist;
  final void Function(Tag tag)? onOpenWiki;
  final BooruConfigAuth auth;
  final bool initiallyMultiSelectEnabled;
  final Widget Function(Widget child, String tag)? contextMenuBuilder;

  @override
  ConsumerState<ShowTagListPage> createState() => _ShowTagListPageState();
}

class _ShowTagListPageState extends ConsumerState<ShowTagListPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final globalNotifier = ref.watch(globalBlacklistedTagsProvider.notifier);
    final favoriteNotifier = ref.watch(favoriteTagsProvider.notifier);
    final params = (widget.auth, widget.post);

    void onAddToGlobalBlacklist(Tag tag) {
      globalNotifier.addTagWithToast(
        context,
        tag.rawName,
      );
    }

    Future<void> onAddToFavoriteTags(Tag tag) async {
      await favoriteNotifier.add(tag.rawName);

      if (!context.mounted) return;

      showSuccessToast(
        context,
        context.t.tags.added,
        backgroundColor: colorScheme.onSurface,
        textStyle: TextStyle(
          color: colorScheme.surface,
        ),
      );
    }

    return ShowTagListPageScaffold(
      post: widget.post,
      auth: widget.auth,
      initiallyMultiSelectEnabled: widget.initiallyMultiSelectEnabled,
      scrollController: _scrollController,
      actionBar: ref
          .watch(showTagsProvider((widget.auth, widget.post)))
          .maybeWhen(
            data: (originalItems) => ShowTagActionBar(
              auth: widget.auth,
              originalItems: originalItems,
              onAddToBlacklist: widget.onAddToBlacklist,
              onAddToGlobalBlacklist: onAddToGlobalBlacklist,
              onAddToFavoriteTags: onAddToFavoriteTags,
            ),
            orElse: () => const SizedBox.shrink(),
          ),
      list: ref
          .watch(showTagsProvider(params))
          .when(
            data: (tags) => tags.isEmpty
                ? Center(
                    child: Text(
                      context.t.generic.errors.no_data,
                      style: textTheme.bodyLarge,
                    ),
                  )
                : ShowTagList(
                    tags: tags,
                    scrollController: _scrollController,
                    auth: widget.auth,
                    onAddToBlacklist: widget.onAddToBlacklist,
                    onAddToGlobalBlacklist: onAddToGlobalBlacklist,
                    onAddToFavoriteTags: onAddToFavoriteTags,
                    onOpenWiki: widget.onOpenWiki,
                    contextMenuBuilder: widget.contextMenuBuilder,
                  ),
            error: (error, stack) => Center(
              child: Text(
                context.t.tags.loading_tags_error(error: error),
                style: textTheme.bodyLarge,
              ),
            ),
            loading: ShowTagListPlaceholder.new,
          ),
    );
  }
}
