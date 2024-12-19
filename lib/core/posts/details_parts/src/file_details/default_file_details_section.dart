// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../details/details.dart';
import '../../../post/post.dart';
import 'file_details_section.dart';

class DefaultInheritedFileDetailsSection<T extends Post>
    extends StatelessWidget {
  const DefaultInheritedFileDetailsSection({
    super.key,
    this.initialExpanded = false,
  });

  final bool initialExpanded;

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<T>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        initialExpanded: initialExpanded,
      ),
    );
  }
}

class DefaultFileDetailsSection extends StatelessWidget {
  const DefaultFileDetailsSection({
    super.key,
    required this.post,
    this.uploaderName,
    this.customDetails,
    this.initialExpanded = false,
  });

  final Post post;
  final bool initialExpanded;
  final String? uploaderName;
  final Map<String, Widget>? customDetails;

  @override
  Widget build(BuildContext context) {
    return FileDetailsSection(
      initialExpanded: initialExpanded,
      post: post,
      rating: post.rating,
      uploader: uploaderName != null
          ? Text(
              uploaderName!.replaceAll('_', ' '),
              maxLines: 1,
              style: const TextStyle(
                fontSize: 14,
              ),
            )
          : null,
      customDetails: customDetails,
    );
  }
}
