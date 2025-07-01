// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'posts.dart';

class GelbooruFileDetailsSection extends StatelessWidget {
  const GelbooruFileDetailsSection({
    super.key,
    this.initialExpanded = false,
  });

  final bool initialExpanded;

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<GelbooruPost>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        initialExpanded: initialExpanded,
        uploaderName: post.uploaderName,
      ),
    );
  }
}
