// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/ref.dart';
import '../../listing/providers.dart';
import '../../post/post.dart';
import 'post_count_provider.dart';
import 'result_counter.dart';

class ResultHeaderWithProvider extends ConsumerWidget {
  const ResultHeaderWithProvider({
    required this.selectedTagsString,
    required this.onRefresh,
    super.key,
    this.cache = false,
  });

  final bool cache;
  final String selectedTagsString;
  final Future<void> Function(bool maintainPage)? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetcher = ref.watch(postCountRepoProvider(ref.watchConfigSearch));

    if (fetcher == null) return const SizedBox.shrink();

    final provider = cache
        ? cachedPostCountProvider(selectedTagsString)
        : postCountProvider(selectedTagsString);

    return ref.watch(provider).when(
          data: (data) => data != null
              ? ResultHeader(
                  count: data,
                  loading: false,
                  onRefresh: onRefresh != null
                      ? () async {
                          await onRefresh!(true);
                        }
                      : null,
                )
              : const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
          loading: () => const ResultHeader(count: 0, loading: true),
        );
  }
}

class ResultHeaderFromController extends ConsumerWidget {
  const ResultHeaderFromController({
    required this.controller,
    required this.onRefresh,
    super.key,
    this.hasCount = false,
  });

  final bool hasCount;
  final PostGridController<Post> controller;
  final Future<void> Function(bool maintainPage)? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!hasCount) return const SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: controller.count,
      builder: (context, data, _) => data != null
          ? ResultHeader(
              count: data,
              loading: false,
              onRefresh: onRefresh != null
                  ? () async {
                      await onRefresh!(true);
                    }
                  : null,
            )
          : const ResultHeader(count: 0, loading: true),
    );
  }
}

class ResultHeader extends StatelessWidget {
  const ResultHeader({
    required this.count,
    required this.loading,
    super.key,
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

class SliverResultHeader extends StatelessWidget {
  const SliverResultHeader({
    required this.selectedTagString,
    required this.controller,
    super.key,
  });

  final ValueNotifier<String> selectedTagString;
  final PostGridController controller;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth < 250
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: selectedTagString,
                      builder: (context, value, _) => ResultHeaderWithProvider(
                        cache: true,
                        selectedTagsString: value,
                        onRefresh: (maintainPage) => controller.refresh(
                          maintainPage: maintainPage,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                );
        },
      ),
    );
  }
}
