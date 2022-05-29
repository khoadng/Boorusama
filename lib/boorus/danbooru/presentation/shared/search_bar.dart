// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:easy_localization/easy_localization.dart';

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
    this.hintText,
    this.onSubmitted,
  }) : super(key: key);

  final VoidCallback onTap;
  final Widget leading;
  final Widget trailing;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final TextEditingController queryEditingController;
  final ValueChanged<bool> onFocusChanged;
  final String hintText;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = widget.queryEditingController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.queryEditingController == null) {
      _textEditingController.dispose();
    }
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
          child: GestureDetector(
            onTap: () => widget.onTap?.call(),
            child: Row(
              children: [
                SizedBox(width: 10),
                widget.leading ?? SizedBox.shrink(),
                SizedBox(width: 10),
                Expanded(
                  child: FocusScope(
                    child: Focus(
                      onFocusChange: (isFocus) => widget.onFocusChanged?.call(isFocus),
                      child: TextFormField(
                        onFieldSubmitted: (value) => widget.onSubmitted?.call(value),
                        onChanged: (value) => widget.onChanged?.call(value),
                        enabled: widget.enabled,
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(bottom: 11, top: 11, right: 15),
                            hintText: widget.hintText ?? 'search.hint'.tr()),
                        autofocus: widget.autofocus,
                        controller: _textEditingController,
                        style: Theme.of(context).inputDecorationTheme.hintStyle,
                      ),
                    ),
                  ),
                ),
                widget.trailing ?? SizedBox.shrink(),
              ],
            ),
          )),
    );
  }
}
