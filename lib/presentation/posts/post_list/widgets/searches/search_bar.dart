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
    return Material(
      elevation: 4.0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ListTile(
          tileColor: Colors.transparent,
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
          title: Text(
            "Search...",
            style: Theme.of(context).inputDecorationTheme.hintStyle,
          ),
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
      ),
    );
  }
}
