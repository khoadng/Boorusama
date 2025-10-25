// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_anchor/flutter_anchor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/widgets/context_menu_tile.dart';
import '../types/danbooru_upload_post.dart';

class DanbooruUploadPostContextMenu extends ConsumerStatefulWidget {
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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruUploadPostContextMenuState();
}

class _DanbooruUploadPostContextMenuState
    extends ConsumerState<DanbooruUploadPostContextMenu> {
  final _controller = AnchorContextMenuController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnchorContextMenu(
      controller: _controller,
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
                  _controller.hide();
                  widget.onVisibilityChanged(false);
                },
              ),
            ],
          ),
        );
      },
      child: GestureDetector(
        onLongPressStart: (details) {
          _controller.show(details.globalPosition);
        },
        child: widget.child,
      ),
    );
  }
}
