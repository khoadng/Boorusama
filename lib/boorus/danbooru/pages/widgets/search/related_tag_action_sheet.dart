// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

class RelatedTagActionSheet extends ConsumerStatefulWidget {
  const RelatedTagActionSheet({
    super.key,
    required this.relatedTag,
    required this.onSelected,
  });

  final RelatedTag relatedTag;
  final void Function(RelatedTagItem tag) onSelected;

  @override
  ConsumerState<RelatedTagActionSheet> createState() =>
      _RelatedTagActionSheetState();
}

class _RelatedTagActionSheetState extends ConsumerState<RelatedTagActionSheet> {
  late final tags = widget.relatedTag.tags
      .sorted((a, b) => b.cosineSimilarity.compareTo(a.cosineSimilarity));

  @override
  Widget build(BuildContext context) {
    final booru = ref.watchConfig;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: context.navigator.pop,
            icon: const Icon(Symbols.close),
          ),
        ],
        toolbarHeight: kToolbarHeight * 0.75,
        automaticallyImplyLeading: false,
        title: const Text('tag.related.related').tr(),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          visualDensity: VisualDensity.compact,
          title: Text(
            tags[index].tag.replaceUnderscoreWithSpace(),
            style: TextStyle(
              color: ref.getTagColor(context, tags[index].category.name),
            ),
          ),
          trailing: BooruPopupMenuButton(
            onSelected: (value) {
              if (value == 'add_to_current_search') {
                context.navigator.pop();
                widget.onSelected(tags[index]);
              } else if (value == 'open_wiki') {
                context.navigator.pop();
                launchWikiPage(
                  booru.url,
                  tags[index].tag,
                );
              }
            },
            itemBuilder: {
              'add_to_current_search':
                  const Text('tag.related.add_to_current_search').tr(),
              'open_wiki': const Text('tag.related.open_wiki').tr(),
            },
          ),
        ),
        itemCount: tags.length,
      ),
    );
  }
}
