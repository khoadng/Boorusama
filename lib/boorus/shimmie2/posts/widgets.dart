// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'types.dart';

class Shimmie2UploaderFileDetailTile extends StatelessWidget {
  const Shimmie2UploaderFileDetailTile({super.key});

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<Shimmie2Post>(context);
    final uploaderName = post.uploaderName;

    return switch (uploaderName) {
      null => const SizedBox.shrink(),
      final name => UploaderFileDetailTile(
        uploaderName: name,
      ),
    };
  }
}

final kShimmie2PostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<Shimmie2Post>(),
  },
  full: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<Shimmie2Post>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedBasicTagsTile<Shimmie2Post>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<Shimmie2Post>(
          uploader: Shimmie2UploaderFileDetailTile(),
        ),
  },
);
