// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/widgets/context_menu_tile.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../types/danbooru_upload_post.dart';

class DanbooruUploadPostContextMenu extends ConsumerWidget {
  const DanbooruUploadPostContextMenu({
    super.key,
    required this.child,
    required this.post,
    required this.onVisibilityChanged,
  });

  final Widget child;
  final DanbooruUploadPost post;
  final void Function(bool visible) onVisibilityChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnchorContextMenu(
      menuBuilder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            boxShadow: kElevationToShadow[4],
          ),
          constraints: const BoxConstraints(
            maxWidth: 220,
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 4,
            ),
            shrinkWrap: true,
            children: [
              ContextMenuTile(
                title: 'Hide upload',
                onTap: () {
                  context.hideMenu();
                  onVisibilityChanged(false);
                },
              ),
            ],
          ),
        );
      },
      childBuilder: (context) => AdaptiveContextMenuGestureTrigger(
        child: child,
      ),
    );
  }
}
