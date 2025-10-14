// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/tags/tag/providers.dart';
import '../local_providers.dart';
import 'trending_tags.dart';

class TrendingSection extends ConsumerWidget {
  const TrendingSection({
    required this.onTagTap,
    super.key,
  });

  final ValueChanged<String>? onTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigFilter;

    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: 8,
      ),
      child: ref
          .watch(top15TrendingTagsProvider(config))
          .when(
            data: (tags) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                TrendingTags(
                  onTagTap: onTagTap,
                  colorBuilder: (context, name) =>
                      ref.watch(tagColorProvider((config.auth, name))),
                  tags: tags,
                ),
              ],
            ),
            error: (error, stackTrace) => const SizedBox.shrink(),
            loading: () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                TrendingTagsPlaceholder(
                  tags: ref.watch(top15PlaceholderTagsProvider),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        context.t.search.trending.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
