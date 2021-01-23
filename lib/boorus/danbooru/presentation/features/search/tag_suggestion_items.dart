import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:flutter/material.dart';

class TagSuggestionItems extends StatelessWidget {
  const TagSuggestionItems({
    Key key,
    @required List<Tag> tags,
    @required this.onItemTap,
  })  : _tags = tags,
        super(key: key);

  final List<Tag> _tags;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ListTile(
            onTap: () => onItemTap(_tags[index].rawName),
            trailing: Text(_tags[index].postCount.toString(),
                style: TextStyle(color: Colors.grey)),
            title: Text(
              _tags[index].displayName,
              style: TextStyle(color: Color(_tags[index].tagHexColor)),
            ),
          ),
          childCount: _tags.length,
        ),
      ),
      // Material(
      //   color: Theme.of(context).scaffoldBackgroundColor,
      //   elevation: 4.0,
      //   borderRadius: BorderRadius.circular(8),
      //   child: ScrollConfiguration(
      //     behavior: NoGlowScrollBehavior(),
      //     child: ListView.builder(
      //       // shrinkWrap: true,
      //       // itemCount: _tags.length > 6 ? 6 : _tags.length,
      //       // physics: const NeverScrollableScrollPhysics(),
      //       itemCount: _tags.length,
      //       itemBuilder: (context, index) {
      //         return ListTile(
      //           onTap: () => onItemTap(_tags[index].rawName),
      //           trailing: Text(_tags[index].postCount.toString(),
      //               style: TextStyle(color: Colors.grey)),
      //           title: Text(
      //             _tags[index].displayName,
      //             style: TextStyle(color: Color(_tags[index].tagHexColor)),
      //           ),
      //         );
      //       },
      //     ),
      //   ),
      // ),
    ]);
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
