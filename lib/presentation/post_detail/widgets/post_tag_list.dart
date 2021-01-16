import 'package:boorusama/application/post_detail/tags/tags_state_notifier.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/domain/tags/tag_category.dart';
import 'package:boorusama/presentation/search/search_page.dart';
import 'package:boorusama/presentation/wiki/wiki_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_tags/flutter_tags.dart' hide TagsState;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:popup_menu/popup_menu.dart';

final tagsStateNotifierProvider =
    StateNotifierProvider<TagsStateNotifier>((ref) => TagsStateNotifier(ref));

class PostTagList extends StatefulWidget {
  final String tagStringComma;

  PostTagList({
    Key key,
    @required this.tagStringComma,
  }) : super(key: key);

  @override
  _PostTagListState createState() => _PostTagListState();
}

class _PostTagListState extends State<PostTagList> {
  List<Tag> _selectedTag = <Tag>[];
  List<Tag> _artistTags = <Tag>[];
  List<Tag> _copyrightTags = <Tag>[];
  List<Tag> _characterTags = <Tag>[];
  List<Tag> _generalTags = <Tag>[];
  List<Tag> _metaTags = <Tag>[];

  Map<String, GlobalKey> _tagKeys = Map<String, GlobalKey>();
  PopupMenu _menu;
  Tag _currentPopupTag;

  @override
  void initState() {
    Future.delayed(
        Duration.zero,
        () => context
            .read(tagsStateNotifierProvider)
            .getTags(widget.tagStringComma));
    PopupMenu.context = context;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _menu ??= PopupMenu(
      items: [
        MenuItem(
          title: 'Wiki',
          image: Icon(
            Icons.info,
            color: Colors.white70,
          ),
        )
      ],
      onClickMenu: (_) {
        showBarModalBottomSheet(
          expand: false,
          context: context,
          builder: (context, controller) => WikiPage(
            title: _currentPopupTag.displayName,
          ),
        );
      },
      maxColumn: 4,
    );

    return Consumer(
      builder: (context, watch, child) {
        final state = watch(tagsStateNotifierProvider.state);
        return state.when(
          initial: () => SliverList(
            delegate: SliverChildListDelegate(
              [
                Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          loading: () => SliverList(
            delegate: SliverChildListDelegate(
              [
                Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          fetched: (tags) {
            tags.sort((a, b) => a.rawName.compareTo(b.rawName));
            _artistTags = tags
                .where((tag) => tag.category == TagCategory.artist)
                .toList();
            _copyrightTags = tags
                .where((tag) => tag.category == TagCategory.copyright)
                .toList();
            _characterTags = tags
                .where((tag) => tag.category == TagCategory.charater)
                .toList();
            _generalTags = tags
                .where((tag) => tag.category == TagCategory.general)
                .toList();
            _metaTags =
                tags.where((tag) => tag.category == TagCategory.meta).toList();
            return SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (_artistTags.length > 0) _TagBlockTitle(title: "Artist"),
                  _buildTags(_artistTags),
                  if (_characterTags.length > 0)
                    _TagBlockTitle(title: "Character"),
                  _buildTags(_characterTags),
                  if (_copyrightTags.length > 0)
                    _TagBlockTitle(title: "Copyright"),
                  _buildTags(_copyrightTags),
                  if (_generalTags.length > 0) _TagBlockTitle(title: "General"),
                  _buildTags(_generalTags),
                  if (_metaTags.length > 0) _TagBlockTitle(title: "Meta"),
                  _buildTags(_metaTags),
                ],
              ),
            );
          },
          error: (e, m) => SliverList(
            delegate: SliverChildListDelegate(
              [
                Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTags(List<Tag> tags) {
    return Tags(
      alignment: WrapAlignment.start,
      itemCount: tags.length,
      itemBuilder: (index) {
        final tag = tags[index];
        final tagKey = GlobalKey();
        _tagKeys[tag.rawName] = tagKey;

        return ItemTags(
          singleItem: true,
          color: Color(tag.tagHexColor),
          highlightColor: Color(tag.tagHexColor),
          activeColor: Color(tag.tagHexColor),
          textColor: Colors.white,
          textActiveColor: Colors.white,
          index: index,
          onPressed: (i) => showSearch(
            context: context,
            query: tag.rawName,
            delegate: SearchPage(
                searchFieldStyle:
                    Theme.of(context).inputDecorationTheme.hintStyle),
          ),
          onLongPressed: (i) {
            if (_menu.isShow) {
              _menu.dismiss();
            }
            _currentPopupTag = tag;
            _menu.show(widgetKey: _tagKeys[tag.rawName]);
          },
          title: tag.displayName,
          key: tagKey,
        );
      },
    );
  }

  void _handleTagSelected(Tag tag) {
    setState(() {
      if (_selectedTag.contains(tag)) {
        _selectedTag.remove(tag);
      } else {
        _selectedTag.add(tag);
      }
    });
  }

  void _searchTags(List<Tag> tags, BuildContext context) {
    final List<String> tagNames = <String>[];

    for (var tag in tags) {
      tagNames.add(tag.rawName);
    }

    showSearch(
      context: context,
      query: tagNames.join(" ") + " ",
      delegate: SearchPage(
          searchFieldStyle: Theme.of(context).inputDecorationTheme.hintStyle),
    );
  }
}

class _TagBlockTitle extends StatelessWidget {
  final String title;

  const _TagBlockTitle({
    @required this.title,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          const Divider(
            thickness: 1.0,
          ),
          _TagHeader(
            title: title,
          ),
        ]);
  }
}

class _TagHeader extends StatelessWidget {
  final String title;

  const _TagHeader({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}
