// Flutter imports:
import 'package:boorusama/boorus/booru_builder.dart';
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
    required this.onRefresh,
  });

  final List<String> selectedTags;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetcher = ref.watch(booruBuilderProvider)?.postCountFetcher;

    if (fetcher == null) return const SizedBox.shrink();

    return ref.watch(postCountProvider(selectedTags.join(' '))).when(
          data: (data) => data != null
              ? ResultHeader(
                  count: data,
                  loading: false,
                  onRefresh: onRefresh,
                )
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
    this.onRefresh,
  });

  final int count;
  final bool loading;
  final Future<void> Function()? onRefresh;

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
              onRefresh: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}
