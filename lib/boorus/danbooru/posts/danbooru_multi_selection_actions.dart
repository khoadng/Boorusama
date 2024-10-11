// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruMultiSelectionActions extends ConsumerWidget {
  const DanbooruMultiSelectionActions({
    super.key,
    required this.controller,
  });

  final MultiSelectController<DanbooruPost> controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return DefaultMultiSelectionActions(
      controller: controller,
      extraActions: [
        if (config.hasLoginDetails())
          ValueListenableBuilder(
            valueListenable: controller.selectedItemsNotifier,
            builder: (context, selectedPosts, child) {
              return IconButton(
                onPressed: selectedPosts.isNotEmpty
                    ? () async {
                        final shouldEnd =
                            await goToAddToFavoriteGroupSelectionPage(
                          context,
                          selectedPosts,
                        );
                        if (shouldEnd != null && shouldEnd) {
                          controller.disableMultiSelect();
                        }
                      }
                    : null,
                icon: const Icon(Symbols.add),
              );
            },
          ),
      ],
    );
  }
}
