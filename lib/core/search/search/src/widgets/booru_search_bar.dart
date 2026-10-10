// Package imports:
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

class BooruSearchBar extends StatelessWidget {
  const BooruSearchBar({
    super.key,
    this.onTap,
    this.leading,
    this.trailing,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.controller,
    this.hintText,
    this.onSubmitted,
    this.constraints,
    this.focus,
    this.dense,
    this.onTapOutside,
    this.onFocusChanged,
    this.contentPadding,
    this.cursorHeight,
    this.suggestionsFocus,
    this.listbox,
  });

  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final bool autofocus;
  final BoxConstraints? constraints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final String? hintText;
  final FocusNode? focus;
  final bool? dense;
  final VoidCallback? onTapOutside;
  final void Function(bool value)? onFocusChanged;
  final EdgeInsetsGeometry? contentPadding;
  final double? cursorHeight;
  final FocusScopeNode? suggestionsFocus;
  final KurumiListboxController? listbox;

  @override
  Widget build(BuildContext context) => KurumiSearchBar(
    key: key,
    onTap: onTap,
    leading: leading,
    trailing: trailing,
    onChanged: onChanged,
    enabled: enabled,
    autofocus: autofocus,
    controller: controller,
    hintText: hintText ?? context.t.search.hint,
    onSubmitted: onSubmitted,
    constraints: constraints,
    focus: focus,
    dense: dense,
    onTapOutside: onTapOutside,
    onFocusChanged: onFocusChanged,
    contentPadding: contentPadding,
    cursorHeight: cursorHeight,
    suggestionsFocus: suggestionsFocus,
    listbox: listbox,
  );
}
