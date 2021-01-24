import 'package:boorusama/generated/i18n.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key key,
    this.onTap,
    this.leading,
    this.trailing,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.onFocusChanged,
    this.queryEditingController,
  }) : super(key: key);

  final VoidCallback onTap;
  final Widget leading;
  final Widget trailing;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final TextEditingController queryEditingController;
  final ValueChanged<bool> onFocusChanged;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController =
        widget.queryEditingController ?? TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
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
          onTap: () => widget.onTap?.call(),
          title: FocusScope(
            child: Focus(
              onFocusChange: (isFocus) => widget.onFocusChanged?.call(isFocus),
              child: TextFormField(
                onChanged: (value) => widget.onChanged(value),
                enabled: widget.enabled,
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.only(bottom: 11, top: 11, right: 15),
                    hintText: I18n.of(context).searchHint),
                autofocus: widget.autofocus,
                controller: _textEditingController,
                style: Theme.of(context).inputDecorationTheme.hintStyle,
              ),
            ),
          ),
          leading: widget.leading,
          trailing: widget.trailing,
        ),
      ),
    );
  }
}
