// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
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
    return KurumiContextMenu(
      menuItemsBuilder: (context) => [
        KurumiContextMenuTile(
          title: 'Hide upload',
          onTap: () => onVisibilityChanged(false),
        ),
      ],
      child: child,
    );
  }
}
