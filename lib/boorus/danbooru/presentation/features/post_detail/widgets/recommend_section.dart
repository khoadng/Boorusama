// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/posts/posts.dart';
import 'package:boorusama/core/core.dart';

class RecommendPostSection extends StatelessWidget {
  const RecommendPostSection({
    Key? key,
    required this.posts,
    required this.header,
    required this.imageQuality,
  }) : super(key: key);

  final List<Post> posts;
  final Widget header;
  final ImageQuality imageQuality;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        Padding(
          padding: const EdgeInsets.all(4),
          child: PreviewPostGrid(
            posts: posts,
            imageQuality: imageQuality,
          ),
        ),
      ],
    );
  }
}
