// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/posts/details/types.dart';
import '../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../core/search/search/routes.dart';
import '../../../posts/types.dart';

class MoebooruUploaderFileDetailTile extends ConsumerWidget {
  const MoebooruUploaderFileDetailTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<MoebooruPost>(context);
    final uploaderName = post.uploaderName;

    return switch (uploaderName) {
      null => const SizedBox.shrink(),
      final name => UploaderFileDetailTile(
        uploaderName: name,
        onSearch: () => goToSearchPage(ref, tag: 'user:$name'),
      ),
    };
  }
}
