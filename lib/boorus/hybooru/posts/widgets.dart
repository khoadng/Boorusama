// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'types.dart';

class HybooruUploaderFileDetailTile extends StatelessWidget {
  const HybooruUploaderFileDetailTile({super.key});

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<HybooruPost>(context);
    final uploaderName = post.uploaderName;

    return switch (uploaderName) {
      null => const SizedBox.shrink(),
      final name => UploaderFileDetailTile(
        uploaderName: name,
      ),
    };
  }
}

final kHybooruPostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<HybooruPost>(),
  },
  full: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<HybooruPost>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedTagsTile<HybooruPost>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<HybooruPost>(
          uploader: HybooruUploaderFileDetailTile(),
        ),
  },
);
