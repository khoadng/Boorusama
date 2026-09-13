import 'package:material_ui/material_ui.dart';

import 'text_field.dart';

class KurumiSearchBar extends StatefulWidget {
  const KurumiSearchBar({
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
    this.textInputAction,
    this.constraints,
    this.focus,
    this.dense,
    this.onTapOutside,
    this.onFocusChanged,
    this.contentPadding,
    this.cursorHeight,
  });

  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final bool autofocus;
  final BoxConstraints? constraints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final String? hintText;
  final FocusNode? focus;
  final bool? dense;
  final VoidCallback? onTapOutside;
  final void Function(bool value)? onFocusChanged;
  final EdgeInsetsGeometry? contentPadding;
  final double? cursorHeight;

  @override
  State<KurumiSearchBar> createState() => _KurumiSearchBarState();
}

class _KurumiSearchBarState extends State<KurumiSearchBar> {
  late TextEditingController controller =
      widget.controller ?? TextEditingController();

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textField = KurumiTextField(
      focusNode: widget.focus,
      cursorHeight: widget.cursorHeight,
      keyboardType: TextInputType.text,
      textInputAction: widget.textInputAction,
      autocorrect: false,
      onTapOutside: (event) {
        if (widget.onTapOutside == null) {
          widget.focus?.unfocus();
        } else {
          widget.onTapOutside?.call();
        }
      },
      onSubmitted: (value) =>
          value.isNotEmpty ? widget.onSubmitted?.call(value) : null,
      onChanged: (value) => widget.onChanged?.call(value),
      enabled: widget.enabled,
      decoration: InputDecoration(
        isDense: widget.dense,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: InputBorder.none,
        fillColor: Colors.transparent,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hoverColor: Colors.transparent,
        contentPadding:
            widget.contentPadding ?? const EdgeInsets.symmetric(vertical: 12),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      autofocus: widget.autofocus,
      controller: controller,
    );

    final actsAsButton = !widget.enabled && widget.onTap != null;
    final searchField = Semantics(
      button: actsAsButton ? true : null,
      enabled: actsAsButton ? true : null,
      label: actsAsButton ? widget.hintText : null,
      onTap: actsAsButton ? widget.onTap : null,
      excludeSemantics: actsAsButton,
      child: textField,
    );

    final searchBar = DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: () => widget.onTap?.call(),
        child: Row(
          children: [
            const SizedBox(width: 4),
            widget.leading ?? const SizedBox(width: 8),
            const SizedBox(width: 4),
            Expanded(
              child: searchField,
            ),
            widget.trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );

    return searchBar;
  }
}
