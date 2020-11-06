import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/application/tags/tag_list/bloc/tag_list_bloc.dart';
import 'package:boorusama/application/wikis/wiki/bloc/wiki_bloc.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/domain/tags/tag_category.dart';
import 'package:boorusama/presentation/tags/wikis/wiki_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostTagList extends StatelessWidget {
  PostTagList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<TagListBloc, TagListState>(
            builder: (context, state) {
              if (state is TagListLoaded) {
                final tags = state.tags
                  ..sort((a, b) => a.rawName.compareTo(b.rawName));
                final artistTags = tags
                    .where((tag) => tag.category == TagCategory.artist)
                    .toList();
                final copyrightTags = tags
                    .where((tag) => tag.category == TagCategory.copyright)
                    .toList();
                final characterTags = tags
                    .where((tag) => tag.category == TagCategory.charater)
                    .toList();
                final generalTags = tags
                    .where((tag) => tag.category == TagCategory.general)
                    .toList();
                final metaTags = tags
                    .where((tag) => tag.category == TagCategory.meta)
                    .toList();

                final list = <Widget>[];

                if (artistTags.isNotEmpty) {
                  list.add(_SliverTagBlockTitle(
                    title: "Artist",
                  ));
                  list.add(_SliverTagList(tags: artistTags));
                }

                if (copyrightTags.isNotEmpty) {
                  list.add(_SliverTagBlockTitle(
                    title: "Copyright",
                  ));
                  list.add(_SliverTagList(tags: copyrightTags));
                }

                if (characterTags.isNotEmpty) {
                  list.add(_SliverTagBlockTitle(
                    title: "Character",
                  ));
                  list.add(_SliverTagList(tags: characterTags));
                }

                if (generalTags.isNotEmpty) {
                  list.add(_SliverTagBlockTitle(
                    title: "General",
                  ));
                  list.add(_SliverTagList(tags: generalTags));
                }

                if (metaTags.isNotEmpty) {
                  list.add(_SliverTagBlockTitle(
                    title: "Meta",
                  ));
                  list.add(_SliverTagList(tags: metaTags));
                }
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CustomScrollView(
                    slivers: list,
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _SliverTagList extends StatelessWidget {
  const _SliverTagList({
    Key key,
    @required this.tags,
  }) : super(key: key);

  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _TagTile(
          title: tags[index].displayName,
          hexColor: tags[index].tagHexColor,
          postCount: tags[index].postCount.toString(),
          onTap: () => _handleTap(tags[index], context),
          onLongPress: () => _handLongPress(tags[index], context),
        );
      }, childCount: tags.length),
    );
  }

  void _handleTap(Tag tag, BuildContext context) {
    BlocProvider.of<PostListBloc>(context).add(GetPost(tag.rawName, 1));
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
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

class _TagTile extends StatelessWidget {
  final String postCount;
  final int hexColor;
  final String title;
  final Function onTap;
  final Function onLongPress;

  const _TagTile({
    Key key,
    @required this.postCount,
    @required this.hexColor,
    @required this.title,
    @required this.onTap,
    @required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        visualDensity: VisualDensity(horizontal: 0, vertical: -4),
        trailing: Text(postCount, style: TextStyle(color: Colors.grey)),
        onTap: () => onTap(),
        onLongPress: () => onLongPress(),
        title: Text(
          title,
          style: TextStyle(
            color: Color(hexColor),
          ),
        ));
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
