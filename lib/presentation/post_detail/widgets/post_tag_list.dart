import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/domain/tags/tag_category.dart';
import 'package:boorusama/presentation/wiki/wiki_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:popup_menu/popup_menu.dart';

class PostTagList extends StatefulWidget {
  final List<Tag> tags;

  PostTagList({
    Key key,
    @required this.tags,
  }) : super(key: key);

  @override
  _PostTagListState createState() => _PostTagListState();
}

class _PostTagListState extends State<PostTagList> {
  List<Tag> _selectedTag = <Tag>[];

  @override
  Widget build(BuildContext context) {
    widget.tags.sort((a, b) => a.rawName.compareTo(b.rawName));
    final artistTags =
        widget.tags.where((tag) => tag.category == TagCategory.artist).toList();
    final copyrightTags = widget.tags
        .where((tag) => tag.category == TagCategory.copyright)
        .toList();
    final characterTags = widget.tags
        .where((tag) => tag.category == TagCategory.charater)
        .toList();
    final generalTags = widget.tags
        .where((tag) => tag.category == TagCategory.general)
        .toList();
    final metaTags =
        widget.tags.where((tag) => tag.category == TagCategory.meta).toList();

    final list = <Widget>[];

    if (artistTags.isNotEmpty) {
      list.add(_SliverTagBlockTitle(
        title: "Artist",
      ));
      list.add(_SliverTagList(
        tags: artistTags,
        onTagTap: _handleTagSelected,
      ));
    }

    if (copyrightTags.isNotEmpty) {
      list.add(_SliverTagBlockTitle(
        title: "Copyright",
      ));
      list.add(_SliverTagList(
        tags: copyrightTags,
        onTagTap: _handleTagSelected,
      ));
    }

    if (characterTags.isNotEmpty) {
      list.add(_SliverTagBlockTitle(
        title: "Character",
      ));
      list.add(_SliverTagList(
        tags: characterTags,
        onTagTap: _handleTagSelected,
      ));
    }

    if (generalTags.isNotEmpty) {
      list.add(_SliverTagBlockTitle(
        title: "General",
      ));
      list.add(_SliverTagList(
        tags: generalTags,
        onTagTap: _handleTagSelected,
      ));
    }

    if (metaTags.isNotEmpty) {
      list.add(_SliverTagBlockTitle(
        title: "Meta",
      ));
      list.add(_SliverTagList(
        tags: metaTags,
        onTagTap: _handleTagSelected,
      ));
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: list,
            ),
          ),
          if (_selectedTag.isNotEmpty)
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: FloatingActionButton(
                child: Icon(Icons.search),
                heroTag: null,
                elevation: 10.0,
                onPressed: () => _searchTags(_selectedTag, context),
              ),
            ),
        ],
      ),
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
    // final List<String> tagNames = <String>[];

    // for (var tag in tags) {
    //   tagNames.add(tag.rawName);
    // }

    // context
    //     .read<PostSearchBloc>()
    //     .add(PostSearchEvent.postSearched(query: tagNames.join(" "), page: 1));
    // Navigator.popUntil(
    //     context, ModalRoute.withName(Navigator.defaultRouteName));
  }
}

class _SliverTagList extends StatefulWidget {
  const _SliverTagList({
    Key key,
    @required this.tags,
    this.onTagTap,
  }) : super(key: key);

  final ValueChanged<Tag> onTagTap;
  final List<Tag> tags;

  @override
  __SliverTagListState createState() => __SliverTagListState();
}

class __SliverTagListState extends State<_SliverTagList> {
  Map<int, GlobalKey> _tagKeys = Map<int, GlobalKey>();
  PopupMenu _menu;
  Tag _currentPopupTag;

  @override
  void initState() {
    super.initState();
    PopupMenu.context = context;
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

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Tags(
            alignment: WrapAlignment.start,
            itemCount: widget.tags.length,
            itemBuilder: (index) {
              final tag = widget.tags[index];
              final tagKey = GlobalKey();
              _tagKeys[index] = tagKey;

              return ItemTags(
                activeColor: Color(tag.tagHexColor),
                index: index,
                onPressed: (i) => widget.onTagTap(tag),
                onLongPressed: (i) {
                  if (_menu.isShow) {
                    _menu.dismiss();
                  }
                  _currentPopupTag = tag;
                  _menu.show(widgetKey: _tagKeys[i.index]);
                },
                title: tag.displayName,
                key: tagKey,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SliverTagBlockTitle extends StatelessWidget {
  final String title;

  const _SliverTagBlockTitle({
    @required this.title,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(
          height: 20,
        ),
        const Divider(
          thickness: 1.0,
        ),
        _TagHeader(
          title: title,
        ),
      ]),
    );
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
