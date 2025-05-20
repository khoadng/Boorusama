// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/tags/tag/providers.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../core/wikis/launcher.dart';
import 'danbooru_related_tag.dart';

class RelatedTagActionSheet extends ConsumerStatefulWidget {
  const RelatedTagActionSheet({
    required this.relatedTag,
    required this.onAdded,
    required this.onNegated,
    super.key,
  });

  final DanbooruRelatedTag relatedTag;
  final void Function(DanbooruRelatedTagItem tag) onAdded;
  final void Function(DanbooruRelatedTagItem tag) onNegated;

  @override
  ConsumerState<RelatedTagActionSheet> createState() =>
      _RelatedTagActionSheetState();
}

class _RelatedTagActionSheetState extends ConsumerState<RelatedTagActionSheet> {
  late final tags = widget.relatedTag.tags
      .sorted((a, b) => b.cosineSimilarity.compareTo(a.cosineSimilarity));

  @override
  Widget build(BuildContext context) {
    final auth = ref.watchConfigAuth;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
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
            tags[index].tag.replaceAll('_', ' '),
            style: TextStyle(
              color: ref
                  .watch(tagColorProvider((auth, tags[index].category.name))),
            ),
          ),
          trailing: BooruPopupMenuButton(
            onSelected: (value) {
              if (value == 'add') {
                Navigator.of(context).pop();
                widget.onAdded(tags[index]);
              } else if (value == 'negate') {
                Navigator.of(context).pop();
                widget.onNegated(tags[index]);
              } else if (value == 'open_wiki') {
                Navigator.of(context).pop();
                launchWikiPage(
                  auth.url,
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
