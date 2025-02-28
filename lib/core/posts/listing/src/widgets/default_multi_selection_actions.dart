// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/widgets/widgets.dart';
import '../../../../bookmarks/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../downloads/downloader.dart';
import '../../../../theme.dart';
import '../../../post/post.dart';

class DefaultMultiSelectionActions<T extends Post> extends ConsumerWidget {
  const DefaultMultiSelectionActions({
    required this.controller,
    super.key,
    this.extraActions,
  });

  final MultiSelectController<T> controller;
  final List<Widget>? extraActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: controller.selectedItemsNotifier,
      builder: (context, selectedPosts, child) {
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
            AddBookmarksButton(
              posts: selectedPosts,
              onPressed: controller.disableMultiSelect,
            ),
            if (extraActions != null) ...extraActions!,
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
                  booruConfig.booruId,
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

class MultiSelectButton extends StatelessWidget {
  const MultiSelectButton({
    required this.icon,
    required this.name,
    required this.onPressed,
    super.key,
  });

  final Widget icon;
  final String name;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconTheme = IconTheme.of(context);

    return InkWell(
      hoverColor: Theme.of(context).hoverColor.withValues(alpha: 0.1),
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onPressed,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            Theme(
              data: ThemeData(
                iconTheme: iconTheme.copyWith(
                  color: onPressed != null
                      ? colorScheme.onSurface
                      : colorScheme.hintColor,
                ),
              ),
              child: icon,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(
                left: 4,
                right: 4,
                bottom: 4,
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: onPressed != null ? null : colorScheme.hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
