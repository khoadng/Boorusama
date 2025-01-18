// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../search/search/routes.dart';
import '../../../../settings/providers.dart';
import '../../../../tags/categories/providers.dart';
import '../../../../tags/tag/providers.dart';
import '../../../../theme/utils.dart';
import '../../../../utils/flutter_utils.dart';
import '../../../details/details.dart';
import '../../../post/post.dart';

class DefaultInheritedTagList<T extends Post> extends ConsumerWidget {
  const DefaultInheritedTagList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<T>(context);

    return SliverToBoxAdapter(
      child: BasicTagList(
        tags: post.tags.toList(),
        unknownCategoryColor: ref.watch(tagColorProvider('general')),
        onTap: (tag) => goToSearchPage(
          context,
          tag: tag,
        ),
      ),
    );
  }
}

class BasicTagList extends ConsumerWidget {
  const BasicTagList({
    required this.tags,
    required this.onTap,
    super.key,
    this.unknownCategoryColor,
  });

  final List<String> tags;
  final void Function(String tag) onTap;
  final Color? unknownCategoryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 8,
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: tags.sorted((a, b) => a.compareTo(b)).map((tag) {
          final categoryAsync = ref.watch(booruTagTypeProvider(tag));

          return GestureDetector(
            onTap: () => onTap(tag),
            child: categoryAsync.maybeWhen(
              data: (category) {
                final colors = context.generateChipColors(
                  category != null
                      ? ref.watch(tagColorProvider(category))
                      : unknownCategoryColor,
                  ref.watch(enableDynamicColoringProvider),
                );

                return Chip(
                  visualDensity: const ShrinkVisualDensity(),
                  backgroundColor: colors?.backgroundColor,
                  side: colors != null
                      ? BorderSide(
                          color: colors.borderColor,
                        )
                      : null,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  label: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.7,
                    ),
                    child: Text(
                      _getTagStringDisplayName(tag),
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors?.foregroundColor,
                      ),
                    ),
                  ),
                );
              },
              orElse: () => Chip(
                visualDensity: const ShrinkVisualDensity(),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                label: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.7,
                  ),
                  child: Text(
                    _getTagStringDisplayName(tag),
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

String _getTagStringDisplayName(String tag) {
  final sanitized = tag.toLowerCase().replaceAll('_', ' ');

  return sanitized.length > 30 ? '${sanitized.substring(0, 30)}...' : sanitized;
}
