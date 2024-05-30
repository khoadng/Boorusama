// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

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
  final TextEditingController? queryEditingController;
  final String? hintText;
  final FocusNode? focus;
  final bool? dense;
  final VoidCallback? onTapOutside;
  final void Function(bool value)? onFocusChanged;
  final EdgeInsetsGeometry? contentPadding;
  final double? cursorHeight;

  @override
  State<BooruSearchBar> createState() => _BooruSearchBarState();
}

class _BooruSearchBarState extends State<BooruSearchBar> {
  late TextEditingController controller =
      widget.queryEditingController ?? TextEditingController();

  @override
  void dispose() {
    if (widget.queryEditingController == null) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusColor: Colors.transparent,
        hoverColor: context.theme.hoverColor,
        onTap: () => widget.onTap?.call(),
        child: Row(
          children: [
            const SizedBox(width: 4),
            widget.leading ?? const SizedBox(width: 8),
            const SizedBox(width: 4),
            Expanded(
              child: BooruTextField(
                focusNode: widget.focus,
                cursorHeight: widget.cursorHeight,
                keyboardType: TextInputType.text,
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
                  contentPadding: widget.contentPadding ??
                      const EdgeInsets.only(
                        bottom: 11,
                        top: 11,
                        right: 4,
                      ),
                  hintText: widget.hintText ?? 'search.hint'.tr(),
                ),
                autofocus: widget.autofocus,
                controller: controller,
                style: context.theme.inputDecorationTheme.hintStyle,
              ),
            ),
            widget.trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
