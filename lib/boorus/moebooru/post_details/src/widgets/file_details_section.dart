// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/posts/details/details.dart';
import '../../../../../core/posts/details_parts/widgets.dart';
import '../../../posts/types.dart';

class MoebooruUploaderFileDetailTile extends StatelessWidget {
  const MoebooruUploaderFileDetailTile({super.key});

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<MoebooruPost>(context);
    final uploaderName = post.uploaderName;

    return switch (uploaderName) {
      null => const SizedBox.shrink(),
      final name => UploaderFileDetailTile(
        uploaderName: name,
      ),
    };
  }
}
