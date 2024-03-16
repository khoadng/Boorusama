// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class TagsTile extends ConsumerWidget {
  const TagsTile({
    super.key,
    required this.post,
    this.onExpand,
    this.onCollapse,
    this.onTagTap,
    this.initialExpanded = false,
    required this.tags,
  });

  final Post post;
  final void Function()? onExpand;
  final void Function()? onCollapse;
  final void Function(Tag tag)? onTagTap;
  final bool initialExpanded;
  final List<TagGroupItem>? tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalNotifier = ref.watch(globalBlacklistedTagsProvider.notifier);

    return Theme(
      data: context.theme.copyWith(
        listTileTheme: context.theme.listTileTheme.copyWith(
          visualDensity: VisualDensity.compact,
        ),
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: initialExpanded,
        title: Text('${post.tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        onExpansionChanged: (value) =>
            value ? onExpand?.call() : onCollapse?.call(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PostTagList(
              tags: tags,
              itemBuilder: (context, tag) => ContextMenu(
                items: [
                  const PopupMenuItem(
                    value: 'copy',
                    child: Text('Copy tag'),
                  ),
                  PopupMenuItem(
                    value: 'add_to_favorites',
                    child: const Text('post.detail.add_to_favorites').tr(),
                  ),
                  const PopupMenuItem(
                    value: 'add_to_global_blacklist',
                    child: Text('Add to global blacklist'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'add_to_favorites') {
                    ref.read(favoriteTagsProvider.notifier).add(tag.rawName);
                  } else if (value == 'copy') {
                    Clipboard.setData(
                      ClipboardData(text: tag.rawName),
                    ).then((value) => showSuccessToast('Copied'));
                  } else if (value == 'add_to_global_blacklist') {
                    globalNotifier.addTagWithToast(tag.rawName);
                  }
                },
                child: PostTagListChip(
                  tag: tag,
                  onTap: () => onTagTap?.call(tag),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
