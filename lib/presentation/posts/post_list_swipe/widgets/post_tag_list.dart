import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/domain/tags/tag_category.dart';
import 'package:flutter/material.dart';

class PostTagList extends StatelessWidget {
  const PostTagList({
    Key key,
    @required List<Tag> tags,
  })  : _tags = tags,
        super(key: key);

  final List<Tag> _tags;

  @override
  Widget build(BuildContext context) {
    final artistTags =
        _tags.where((tag) => tag.category == TagCategory.artist).toList();
    final copyrightTags =
        _tags.where((tag) => tag.category == TagCategory.copyright).toList();
    final characterTags =
        _tags.where((tag) => tag.category == TagCategory.charater).toList();
    final generalTags =
        _tags.where((tag) => tag.category == TagCategory.general).toList();
    final metaTags =
        _tags.where((tag) => tag.category == TagCategory.meta).toList();

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

    return CustomScrollView(slivers: list);
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
        );
      }, childCount: tags.length),
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

  const _TagTile({
    Key key,
    @required this.postCount,
    @required this.hexColor,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        visualDensity: VisualDensity(horizontal: 0, vertical: -4),
        trailing: Text(postCount, style: TextStyle(color: Colors.grey)),
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
