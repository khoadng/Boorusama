// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/posts/details/types.dart';
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/search/search/routes.dart';
import 'types.dart';

class Shimmie2UploaderFileDetailTile extends ConsumerWidget {
  const Shimmie2UploaderFileDetailTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<Shimmie2Post>(context);
    final uploaderName = post.uploaderName;

    return switch (uploaderName) {
      null => const SizedBox.shrink(),
      final name => UploaderFileDetailTile(
        uploaderName: name,
        onSearch: () => goToSearchPage(ref, tag: 'user=$name'),
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
