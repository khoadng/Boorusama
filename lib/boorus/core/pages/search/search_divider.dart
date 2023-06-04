// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/search/selected_tags_notifier.dart';

class SearchDivider extends ConsumerWidget {
  const SearchDivider({
    super.key,
    this.height,
  });

  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(selectedTagsProvider);
    return tags.isNotEmpty
        ? Divider(height: height ?? 15, thickness: 1)
        : const SizedBox.shrink();
  }
}
