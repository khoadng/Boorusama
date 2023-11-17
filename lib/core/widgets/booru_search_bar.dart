// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
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
      child: Card(
        child: GestureDetector(
          onTap: () => widget.onTap?.call(),
          child: Row(
            children: [
              const SizedBox(width: 10),
              widget.leading ?? const SizedBox.shrink(),
              const SizedBox(width: 10),
              Expanded(
                child: Focus(
                  focusNode: widget.focus,
                  onFocusChange: widget.onFocusChanged,
                  child: TextFormField(
                    onTapOutside: (event) {
                      if (widget.onTapOutside == null) {
                        widget.focus?.unfocus();
                      } else {
                        widget.onTapOutside?.call();
                      }
                    },
                    onFieldSubmitted: (value) => value.isNotEmpty
                        ? widget.onSubmitted?.call(value)
                        : null,
                    onChanged: (value) => widget.onChanged?.call(value),
                    enabled: widget.enabled,
                    decoration: InputDecoration(
                      isDense: widget.dense,
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
                    style: context.theme.inputDecorationTheme.hintStyle,
                  ),
                ),
              ),
              widget.trailing ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
