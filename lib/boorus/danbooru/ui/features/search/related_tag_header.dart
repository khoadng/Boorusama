// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/ui/features/tags/tags.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/application/utils.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';

class RelatedTagHeader extends StatefulWidget {
  const RelatedTagHeader({
    super.key,
    required this.relatedTag,
    required this.theme,
  });

  final RelatedTag relatedTag;
  final ThemeMode theme;

  @override
  State<RelatedTagHeader> createState() => _RelatedTagHeaderState();
}

class _RelatedTagHeaderState extends State<RelatedTagHeader> {
  late final tags = [...widget.relatedTag.tags]..shuffle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      height: 50,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          ...tags.take(10).map(
                (item) => _RelatedTagButton(
                  backgroundColor: getTagColor(item.category, widget.theme),
                  onPressed: () => context
                      .read<TagSearchBloc>()
                      .add(TagSearchNewRawStringTagSelected(item.tag)),
                  label: Text(
                    item.tag.removeUnderscoreWithSpace(),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
          const VerticalDivider(
            indent: 12,
            endIndent: 12,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).iconTheme.color,
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(
                  color: Theme.of(context).hintColor,
                ),
              ),
              onPressed: () {
                final bloc = context.read<TagSearchBloc>();
                final page = BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
                  builder: (context, state) {
                    return _RelatedTagActionSheet(
                      relatedTag: widget.relatedTag,
                      theme: widget.theme,
                      onOpenWiki: (tag) => launchWikiPage(
                        state.booru.url,
                        tag,
                      ),
                      onAddToSearch: (tag) =>
                          bloc.add(TagSearchNewRawStringTagSelected(tag)),
                    );
                  },
                );
                if (Screen.of(context).size == ScreenSize.small) {
                  showBarModalBottomSheet(
                    context: context,
                    builder: (context) => page,
                  );
                } else {
                  showSideSheetFromRight(
                    width: 220,
                    body: page,
                    context: context,
                  );
                }
              },
              child: const Text('tag.related.more').tr(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedTagActionSheet extends StatelessWidget {
  const _RelatedTagActionSheet({
    required this.relatedTag,
    required this.theme,
    required this.onAddToSearch,
    required this.onOpenWiki,
  });

  final RelatedTag relatedTag;
  final ThemeMode theme;
  final void Function(String tag) onOpenWiki;
  final void Function(String tag) onAddToSearch;

  @override
  Widget build(BuildContext context) {
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
                    onAddToSearch(relatedTag.tags[index].tag);
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

class _RelatedTagButton extends StatelessWidget {
  const _RelatedTagButton({
    required this.backgroundColor,
    required this.onPressed,
    required this.label,
  });

  final Color backgroundColor;
  final VoidCallback onPressed;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: backgroundColor,
          padding: const EdgeInsets.only(left: 6, right: 2),
          backgroundColor: Theme.of(context).cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          side: BorderSide(
            color: Theme.of(context).hintColor,
          ),
        ),
        onPressed: onPressed,
        icon: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
          child: label,
        ),
        label: const Icon(Icons.add),
      ),
    );
  }
}
