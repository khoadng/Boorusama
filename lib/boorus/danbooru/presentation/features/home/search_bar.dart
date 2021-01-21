import 'package:boorusama/generated/i18n.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/post_list_action.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key key,
    this.onTap,
    this.controller,
    this.leading,
    this.trailing,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.initialQuery,
  }) : super(key: key);

  final VoidCallback onTap;
  final SearchBarController controller;
  final Widget leading;
  final Widget trailing;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final String initialQuery;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  SearchBarController _controller;
  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SearchBarController();
    _textEditingController = TextEditingController(text: widget.initialQuery);
    _controller.searchBarState = this;
  }

  @override
  void dispose() {
    _controller.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  set query(String query) {
    _textEditingController.text = query;
    _textEditingController.selection =
        TextSelection.fromPosition(TextPosition(offset: query.length));
  }

  get query => _textEditingController.text;

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
          onTap: () => widget.onTap?.call(),
          title: TextFormField(
            onChanged: (value) => widget.onChanged(value),
            enabled: widget.enabled,
            decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 11, top: 11, right: 15),
                hintText: I18n.of(context).searchHint),
            autofocus: widget.autofocus,
            controller: _textEditingController,
            style: Theme.of(context).inputDecorationTheme.hintStyle,
          ),
          leading: widget.leading,
          trailing: widget.trailing,
        ),
      ),
    );
  }
}

class SearchBarController {
  _SearchBarState searchBarState;

  String get query {
    // assert(searchBarState != null);
    return searchBarState?.query ?? "";
  }

  set query(String query) {
    assert(searchBarState != null);
    searchBarState.query = query;
  }

  void dispose() {
    searchBarState = null;
  }
}
