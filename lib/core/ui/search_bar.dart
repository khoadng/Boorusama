// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

class BooruSearchBar extends StatefulWidget {
  const BooruSearchBar({
    super.key,
    this.onTap,
    this.leading,
    this.trailing,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.queryEditingController,
    this.hintText,
    this.onSubmitted,
    this.constraints,
    this.focus,
    this.backgroundColor,
  });

  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final bool autofocus;
  final BoxConstraints? constraints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? queryEditingController;
  final String? hintText;
  final FocusNode? focus;
  final Color? backgroundColor;

  @override
  State<BooruSearchBar> createState() => _BooruSearchBarState();
}

class _BooruSearchBarState extends State<BooruSearchBar> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController =
        widget.queryEditingController ?? TextEditingController();
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
    return Center(
      child: ConstrainedBox(
        constraints: widget.constraints ?? const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 4,
          color: widget.backgroundColor ?? Theme.of(context).cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: GestureDetector(
            onTap: () => widget.onTap?.call(),
            child: Row(
              children: [
                const SizedBox(width: 10),
                widget.leading ?? const SizedBox.shrink(),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    focusNode: widget.focus,
                    onFieldSubmitted: (value) =>
                        widget.onSubmitted?.call(value),
                    onChanged: (value) => widget.onChanged?.call(value),
                    enabled: widget.enabled,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                        bottom: 11,
                        top: 11,
                        right: 15,
                      ),
                      hintText: widget.hintText ?? 'search.hint'.tr(),
                    ),
                    autofocus: widget.autofocus,
                    controller: _textEditingController,
                    style: Theme.of(context).inputDecorationTheme.hintStyle,
                  ),
                ),
                widget.trailing ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
