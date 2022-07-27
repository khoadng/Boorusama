// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:side_sheet/side_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/application/utils.dart';
import 'package:boorusama/core/core.dart';

class RelatedTagHeader extends StatefulWidget {
  const RelatedTagHeader({
    Key? key,
    required this.relatedTag,
    required this.theme,
  }) : super(key: key);

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
          ...tags
              .take(10)
              .map(
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
              )
              .toList(),
          const VerticalDivider(
            indent: 12,
            endIndent: 12,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).cardColor,
                onPrimary: Theme.of(context).iconTheme.color,
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
                  SideSheet.right(body: page, context: context);
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
    Key? key,
    required this.relatedTag,
    required this.theme,
    required this.onAddToSearch,
    required this.onOpenWiki,
  }) : super(key: key);

  final RelatedTag relatedTag;
  final ThemeMode theme;
  final void Function(String tag) onOpenWiki;
  final void Function(String tag) onAddToSearch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('tag.related.related').tr(),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: Text(
            relatedTag.tags[index].tag.removeUnderscoreWithSpace(),
            style: TextStyle(
                color: getTagColor(relatedTag.tags[index].category, theme)),
          ),
          onTap: () => showActionListModalBottomSheet(
            context: context,
            children: [
              ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.plus,
                  size: 20,
                ),
                title: const Text('tag.related.add_to_current_search').tr(),
                onTap: () {
                  onAddToSearch(relatedTag.tags[index].tag);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.arrowUpRightFromSquare,
                  size: 20,
                ),
                title: const Text('tag.related.open_wiki').tr(),
                onTap: () {
                  onOpenWiki(relatedTag.tags[index].tag);
                  Navigator.of(context).pop();
                },
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
    Key? key,
    required this.backgroundColor,
    required this.onPressed,
    required this.label,
  }) : super(key: key);

  final Color backgroundColor;
  final VoidCallback onPressed;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(left: 6, right: 2),
          primary: Theme.of(context).cardColor,
          onPrimary: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
