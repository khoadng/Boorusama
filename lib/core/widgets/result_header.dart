// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/widgets/widgets.dart';

class ResultHeaderWithProvider extends ConsumerWidget {
  const ResultHeaderWithProvider({
    super.key,
    required this.selectedTags,
  });

  final List<String> selectedTags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(postCountProvider(selectedTags.join(' '))).when(
          data: (data) => data != null
              ? ResultHeader(count: data, loading: false)
              : const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
          loading: () => const ResultHeader(count: 0, loading: true),
        );
  }
}

class ResultHeader extends StatelessWidget {
  const ResultHeader({
    super.key,
    required this.count,
    required this.loading,
  });

  final int count;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: ResultCounter(
              count: count,
              loading: loading,
            ),
          ),
        ],
      ),
    );
  }
}
