// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

class ResultHeaderWithProvider extends ConsumerWidget {
  const ResultHeaderWithProvider({
    super.key,
    required this.selectedTags,
  });

  final List<String> selectedTags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postCountState = ref.watch(postCountProvider);

    if (postCountState.isLoading(selectedTags)) {
      return const ResultHeader(count: 0, loading: true);
    } else if (postCountState.isEmpty(selectedTags)) {
      return const SizedBox.shrink();
    } else {
      return postCountState.getPostCount(selectedTags).toOption().fold(
            () => const SizedBox.shrink(),
            (count) => ResultHeader(
              count: count,
              loading: false,
            ),
          );
    }
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
