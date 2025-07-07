// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/widgets/widgets.dart';
import '../../../../bookmarks/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../downloads/downloader/providers.dart';
import '../../../post/post.dart';
import 'post_grid_controller.dart';

class DefaultMultiSelectionActions<T extends Post> extends ConsumerWidget {
  const DefaultMultiSelectionActions({
    required this.controller,
    required this.postController,
    super.key,
    this.extraActions,
    this.bookmark = true,
  });

  final MultiSelectController controller;
  final PostGridController<T> postController;
  final bool bookmark;
  final List<Widget> Function(List<T> selectedPosts)? extraActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: controller.selectedItemsNotifier,
      builder: (context, selectedKeys, child) {
        final selectedPosts = postController.getPostsFromIds(
          selectedKeys.toList(),
        );

        return MultiSelectionActionBar(
          children: [
            MultiSelectButton(
              onPressed: selectedPosts.isNotEmpty
                  ? () {
                      ref.bulkDownload(selectedPosts);

                      controller.disableMultiSelect();
                    }
                  : null,
              icon: const Icon(Symbols.download),
              name: 'download.download'.tr(),
            ),
            if (bookmark)
              AddBookmarksButton(
                posts: selectedPosts,
                onPressed: controller.disableMultiSelect,
              ),
            if (extraActions != null) ...extraActions!(selectedPosts),
          ],
        );
      },
    );
  }
}

class AddBookmarksButton extends ConsumerWidget {
  const AddBookmarksButton({
    required this.posts,
    required this.onPressed,
    super.key,
  });

  final void Function() onPressed;
  final List<Post> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;

    return MultiSelectButton(
      name: 'Bookmark',
      onPressed: posts.isNotEmpty
          ? () async {
              unawaited(
                ref.bookmarks.addBookmarksWithToast(
                  context,
                  booruConfig,
                  booruConfig.url,
                  posts,
                ),
              );
              onPressed();
            }
          : null,
      icon: const Icon(Symbols.bookmark_add),
    );
  }
}
