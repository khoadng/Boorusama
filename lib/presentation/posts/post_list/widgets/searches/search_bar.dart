import 'package:boorusama/presentation/posts/post_list/models/post_list_action.dart';
import 'package:flutter/material.dart';

import 'post_search.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    Key key,
    @required this.onMenuTap,
    @required this.onSearched,
    @required this.onMoreSelected,
  }) : super(key: key);

  final VoidCallback onMenuTap;
  final ValueChanged<String> onSearched;
  final ValueChanged<PostListAction> onMoreSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      // alignment: Alignment.center,
      // height: kToolbarHeight - 10,
      // width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      // color: Theme.of(context).cardTheme.color),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        onTap: () {
          showSearch(
            context: context,
            delegate: PostSearch(
                onSearched: onSearched,
                searchFieldStyle:
                    Theme.of(context).inputDecorationTheme.hintStyle),
          );
        },
        title: Text("Search..."),
        trailing: PopupMenuButton<PostListAction>(
          onSelected: (value) => onMoreSelected(value),
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<PostListAction>>[
            const PopupMenuItem<PostListAction>(
              value: PostListAction.downloadAll,
              child: Text('Download all'),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: onMenuTap,
        ),
      ),
    );
  }
}
