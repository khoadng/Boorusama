import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/application/wikis/wiki/bloc/wiki_bloc.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/domain/tags/tag_category.dart';
import 'package:boorusama/presentation/tags/wikis/wiki_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
    var start = DateTime.now();

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

    var diff = DateTime.now().difference(start).inMicroseconds;
    print("TEST: Completed parsing post in $diff us");

    return Scaffold(
      floatingActionButton: Column(
        children: <Widget>[
          if (_selectedTag.isNotEmpty)
            FloatingActionButton(
                child: Icon(Icons.search),
                heroTag: null,
                elevation: 10.0,
                onPressed: () => _searchTags(_selectedTag, context)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: widget.tags.isNotEmpty
            ? CustomScrollView(
                slivers: list,
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
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
    final List<String> tagNames = <String>[];

    for (var tag in tags) {
      tagNames.add(tag.rawName);
    }

    BlocProvider.of<PostListBloc>(context).add(GetPost(tagNames.join(" "), 1));
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
  }
}

class _SliverTagList extends StatelessWidget {
  const _SliverTagList({
    Key key,
    @required this.tags,
    this.onTagTap,
  }) : super(key: key);

  final ValueChanged<Tag> onTagTap;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Tags(
          itemCount: tags.length,
          itemBuilder: (index) {
            final tag = tags[index];

            return Tooltip(
              preferBelow: false,
              message: tag.postCount.toString(),
              child: ItemTags(
                activeColor: Color(tag.tagHexColor),
                index: index,
                onPressed: (i) => onTagTap(tag),
                title: tag.displayName,
                key: Key(index.toString()),
              ),
            );
          },
        ),
      ]),
    );
  }

  void _handLongPress(Tag tag, BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context, controller) => ModalFit(tag: tag),
    );
  }
}

class ModalFit extends StatelessWidget {
  final Tag tag;
  const ModalFit({
    Key key,
    @required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('Wiki page'),
            leading: Icon(Icons.info_outline),
            onTap: () {
              BlocProvider.of<WikiBloc>(context)
                  .add(WikiRequested(tag.rawName));
              Navigator.of(context).pop();
              showBarModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context, controller) => WikiPage(
                  title: tag.displayName,
                ),
              );
            },
          ),
        ],
      ),
    ));
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
        SizedBox(
          height: 20,
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
    return Text(
      title,
      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900),
    );
  }
}
