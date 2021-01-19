import 'package:boorusama/generated/i18n.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/post_list_action.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key key,
    @required this.onMenuTap,
    @required this.onTap,
    @required this.onMoreSelected,
    this.onRemoveTap,
    @required this.controller,
  })  : assert(controller != null),
        super(key: key);

  final VoidCallback onMenuTap;
  final VoidCallback onRemoveTap;
  final VoidCallback onTap;
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
          onTap: () => widget.onTap(),
          title: Text(
            _currentQuery.isEmpty ? I18n.of(context).searchHint : _currentQuery,
            style: Theme.of(context).inputDecorationTheme.hintStyle,
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
