// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../details/types.dart';
import '../../../post/types.dart';
import 'file_details_section.dart';

class DefaultInheritedFileDetailsSection<T extends Post>
    extends StatelessWidget {
  const DefaultInheritedFileDetailsSection({
    super.key,
    this.initialExpanded = false,
    this.uploader,
  });

  final bool initialExpanded;
  final Widget? uploader;

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<T>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        initialExpanded: initialExpanded,
        uploader:
            uploader ??
            switch (post.uploaderName) {
              null => null,
              final name => UploaderFileDetailTile(
                uploaderName: name,
              ),
            },
      ),
    );
  }
}

class DefaultFileDetailsSection extends StatelessWidget {
  const DefaultFileDetailsSection({
    required this.post,
    super.key,
    this.uploader,
    this.customDetails,
    this.initialExpanded = false,
  });

  final Post post;
  final bool initialExpanded;
  final Widget? uploader;
  final List<Widget>? customDetails;

  @override
  Widget build(BuildContext context) {
    return FileDetailsSection(
      initialExpanded: initialExpanded,
      post: post,
      rating: post.rating,
      uploader: uploader,
      customDetails: customDetails,
    );
  }
}
