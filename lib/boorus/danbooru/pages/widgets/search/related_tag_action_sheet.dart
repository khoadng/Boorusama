// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/core/configs/providers.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/wikis/wikis.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

class RelatedTagActionSheet extends ConsumerStatefulWidget {
  const RelatedTagActionSheet({
    super.key,
    required this.relatedTag,
    required this.onAdded,
    required this.onNegated,
  });

  final RelatedTag relatedTag;
  final void Function(RelatedTagItem tag) onAdded;
  final void Function(RelatedTagItem tag) onNegated;

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
              color: ref.watch(tagColorProvider(tags[index].category.name)),
            ),
          ),
          trailing: BooruPopupMenuButton(
            onSelected: (value) {
              if (value == 'add') {
                context.navigator.pop();
                widget.onAdded(tags[index]);
              } else if (value == 'negate') {
                context.navigator.pop();
                widget.onNegated(tags[index]);
              } else if (value == 'open_wiki') {
                context.navigator.pop();
                launchWikiPage(
                  booru.url,
                  tags[index].tag,
                );
              }
            },
            itemBuilder: {
              'add': const Text('Add'),
              'negate': const Text('Negate'),
              'open_wiki': const Text('tag.related.open_wiki').tr(),
            },
          ),
        ),
        itemCount: tags.length,
      ),
    );
  }
}
