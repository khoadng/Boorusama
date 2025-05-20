// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
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

    return ref.watch(top15TrendingTagsProvider(config)).when(
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
        );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'search.trending'.tr().toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
