// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../listing/providers.dart';
import '../../post/types.dart';
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
    final config = ref.watchConfigSearch;
    final params = (config, selectedTagsString);
    final fetcher = ref.watch(postCountRepoProvider(config));

    if (fetcher == null) return const SizedBox.shrink();

    final provider = cache
        ? cachedPostCountProvider(params)
        : postCountProvider(params);

    return switch (ref.watch(provider)) {
      AsyncData(value: final count?) => ResultHeader(
        count: count,
        onRefresh: switch (onRefresh) {
          final f? => () => f(true),
          _ => null,
        },
      ),
      AsyncLoading() => const ResultHeader.loading(),
      _ => const SizedBox.shrink(),
    };
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
      builder: (context, data, _) => switch (data) {
        final count? => ResultHeader(
          count: count,
          onRefresh: switch (onRefresh) {
            final f? => () => f(true),
            _ => null,
          },
        ),
        null => const ResultHeader.loading(),
      },
    );
  }
}

class ResultHeader extends StatelessWidget {
  const ResultHeader({
    required this.count,
    super.key,
    this.onRefresh,
  }) : loading = false;

  const ResultHeader.loading({
    super.key,
  }) : count = 0,
       loading = true,
       onRefresh = null;

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
