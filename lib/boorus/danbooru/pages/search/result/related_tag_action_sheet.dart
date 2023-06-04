// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/pages/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/foundation/i18n.dart';

class RelatedTagActionSheet extends ConsumerWidget {
  const RelatedTagActionSheet({
    super.key,
    required this.relatedTag,
  });

  final RelatedTag relatedTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    final booru = ref.watch(currentBooruProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close),
          ),
        ],
        toolbarHeight: kToolbarHeight * 0.75,
        automaticallyImplyLeading: false,
        title: const Text('tag.related.related').tr(),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          title: Text(
            relatedTag.tags[index].tag.removeUnderscoreWithSpace(),
            style: TextStyle(
              color: getTagColor(relatedTag.tags[index].category, theme),
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
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    //FIXME: implement this
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
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  onTap: () {
                    Navigator.of(context).pop();
                    launchWikiPage(
                      booru.url,
                      relatedTag.tags[index].tag,
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
        itemCount: relatedTag.tags.length,
      ),
    );
  }
}
