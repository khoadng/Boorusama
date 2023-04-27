// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/ui/tags.dart';
import 'package:boorusama/core/utils.dart';

class RelatedTagActionSheet extends StatelessWidget {
  const RelatedTagActionSheet({
    super.key,
    required this.relatedTag,
    required this.onAddToSearch,
    required this.onOpenWiki,
  });

  final RelatedTag relatedTag;
  final void Function(String tag) onOpenWiki;
  final void Function(RelatedTagItem tag) onAddToSearch;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

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
                    onAddToSearch(relatedTag.tags[index]);
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
                    onOpenWiki(relatedTag.tags[index].tag);
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
