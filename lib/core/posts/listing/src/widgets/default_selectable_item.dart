// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../post/post.dart';
import '../../../post/routes.dart';

class DefaultSelectableItem<T extends Post> extends StatelessWidget {
  const DefaultSelectableItem({
    required this.multiSelectController,
    required this.index,
    required this.post,
    required this.item,
    super.key,
  });

  final MultiSelectController multiSelectController;
  final int index;
  final T post;
  final Widget item;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: multiSelectController.selectedItemsNotifier,
      builder: (_, selectedItems, _) => SelectableItem(
        index: index,
        isSelected: selectedItems.contains(post.id),
        onTap: () => multiSelectController.toggleSelection(post.id),
        onLongPress: () {
          goToImagePreviewPage(context, post);
        },
        itemBuilder: (context, isSelected) => item,
      ),
    );
  }
}
