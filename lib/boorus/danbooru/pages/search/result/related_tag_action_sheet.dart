// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';

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
    final booru = ref.watch(currentBooruProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: context.navigator.pop,
            icon: const Icon(Icons.close),
          ),
        ],
        toolbarHeight: kToolbarHeight * 0.75,
        automaticallyImplyLeading: false,
        title: const Text('tag.related.related').tr(),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          visualDensity: const ShrinkVisualDensity(),
          title: Text(
            tags[index].tag.replaceUnderscoreWithSpace(),
            style: TextStyle(
              color: getTagColor(tags[index].category, context.themeMode),
            ),
          ),
          trailing: PopupMenuButton(
            padding: const EdgeInsets.all(1),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: ListTile(
                  visualDensity: const ShrinkVisualDensity(),
                  onTap: () {
                    context.navigator.pop();
                    context.navigator.pop();
                    widget.onSelected(tags[index]);
                  },
                  title: const Text('tag.related.add_to_current_search').tr(),
                  trailing: const FaIcon(
                    FontAwesomeIcons.plus,
                    size: 20,
                  ),
                ),
              ),
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: ListTile(
                  visualDensity: const ShrinkVisualDensity(),
                  onTap: () {
                    context.navigator.pop();
                    launchWikiPage(
                      booru.url,
                      tags[index].tag,
                    );
                  },
                  title: const Text('tag.related.open_wiki').tr(),
                  trailing: const FaIcon(
                    FontAwesomeIcons.arrowUpRightFromSquare,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        itemCount: tags.length,
      ),
    );
  }
}
