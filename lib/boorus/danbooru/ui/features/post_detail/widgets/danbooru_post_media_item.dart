// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_media_item.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/widgets.dart';
import 'package:boorusama/core/domain/posts.dart';

class DanbooruPostMediaItem extends StatelessWidget {
  const DanbooruPostMediaItem({
    super.key,
    required this.post,
    required this.onCached,
    this.onTap,
    this.onZoomUpdated,
    this.previewCacheManager,
    this.enableNotes = true,
    required this.notes,
  });

  final Post post;
  final void Function(String? path) onCached;
  final VoidCallback? onTap;
  final void Function(bool zoom)? onZoomUpdated;
  final CacheManager? previewCacheManager;
  final bool enableNotes;
  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return PostMediaItem(
      post: post,
      onCached: onCached,
      onTap: onTap,
      onZoomUpdated: onZoomUpdated,
      previewCacheManager: previewCacheManager,
      imageOverlayBuilder: (constraints) => [
        if (enableNotes)
          ...notes
              .map((e) => e.adjustNoteCoordFor(
                    post,
                    widthConstraint: constraints.maxWidth,
                    heightConstraint: constraints.maxHeight,
                  ))
              .map((e) => PostNote(
                    coordinate: e.coordinate,
                    content: e.content,
                  )),
      ],
    );
  }
}
