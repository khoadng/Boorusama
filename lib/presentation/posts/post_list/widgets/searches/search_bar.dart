import 'package:boorusama/presentation/posts/post_list/models/post_list_action.dart';
import 'package:flutter/material.dart';

import 'post_search.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key key,
    @required this.onMenuTap,
    @required this.onSearched,
    @required this.onMoreSelected,
    @required this.onRemoveTap,
    @required this.controller,
  })  : assert(controller != null),
        super(key: key);

  final VoidCallback onMenuTap;
  final VoidCallback onRemoveTap;
  final ValueChanged<String> onSearched;
  final ValueChanged<PostListAction> onMoreSelected;
  final SearchBarController controller;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  String _currentQuery = "";

  @override
  void initState() {
    super.initState();
    widget.controller.searchBarState = this;
  }

  set query(String query) {
    setState(() {
      _currentQuery = query;
    });
  }

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
              query: _currentQuery,
              context: context,
              delegate: PostSearch(
                  onSearched: (value) {
                    if (mounted) {
                      setState(() {
                        _currentQuery = value;
                      });
                    }

                    widget.onSearched(_currentQuery);
                  },
                  searchFieldStyle:
                      Theme.of(context).inputDecorationTheme.hintStyle),
            );
          },
          title: Text(
            _currentQuery.isEmpty ? "Search..." : _currentQuery,
            style: Theme.of(context).inputDecorationTheme.hintStyle,
          ),
          trailing: Wrap(
            children: <Widget>[
              if (_currentQuery.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _currentQuery = "";
                    });
                    widget.onRemoveTap();
                  },
                ),
              // PopupMenuButton<PostListAction>(
              //   onSelected: (value) => widget.onMoreSelected(value),
              //   itemBuilder: (BuildContext context) =>
              //       <PopupMenuEntry<PostListAction>>[
              //     const PopupMenuItem<PostListAction>(
              //       value: PostListAction.downloadAll,
              //       child: Text('Download all'),
              //     ),
              //   ],
              // ),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: widget.onMenuTap,
          ),
        ),
      ),
    );
  }
}

class SearchBarController {
  _SearchBarState searchBarState;

  void assignQuery(String query) {
    assert(searchBarState != null);

    searchBarState.query = query;
  }

  void dispose() {
    searchBarState = null;
  }
}
