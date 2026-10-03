import 'package:flutter/services.dart';
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
    this.constraints,
    this.focus,
    this.dense,
    this.onTapOutside,
    this.onFocusChanged,
    this.contentPadding,
    this.cursorHeight,
    this.suggestionsFocus,
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

  /// Scope of suggestions shown under the bar while typing. When it holds
  /// any control, the down arrow moves into it instead of leaving the bar,
  /// and back returns to the bar instead of leaving the page while the field
  /// or a suggestion has focus.
  final FocusScopeNode? suggestionsFocus;

  @override
  State<KurumiSearchBar> createState() => _KurumiSearchBarState();
}

class _KurumiSearchBarState extends State<KurumiSearchBar> {
  late TextEditingController controller =
      widget.controller ?? TextEditingController();

  // Arrow keys stop on this node instead of the text field, so remote and
  // keyboard users can pass over the bar without opening the keyboard.
  final _barNode = FocusNode(debugLabel: 'KurumiSearchBar');
  late final _fieldNode = (widget.focus ?? FocusNode())..skipTraversal = true;

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    if (widget.focus == null) {
      _fieldNode.dispose();
    }
    _barNode.dispose();

    super.dispose();
  }

  void _activate() => switch (widget.enabled) {
    true => _fieldNode.requestFocus(),
    false => widget.onTap?.call(),
  };

  // Up and down mean nothing in a single-line field, so they leave it the
  // same way they would leave the bar.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) => switch (event) {
    KeyDownEvent(logicalKey: LogicalKeyboardKey.escape)
        when _fieldNode.hasFocus =>
      _stopEditing(),
    KeyDownEvent(logicalKey: LogicalKeyboardKey.arrowUp)
        when _fieldNode.hasFocus =>
      _stopEditing(then: TraversalDirection.up),
    KeyDownEvent(logicalKey: LogicalKeyboardKey.arrowDown)
        when _fieldNode.hasFocus =>
      switch (_firstSuggestion()) {
        final suggestion? => _enterSuggestions(suggestion),
        null => _stopEditing(then: TraversalDirection.down),
      },
    _ => KeyEventResult.ignored,
  };

  FocusNode? _firstSuggestion() => widget.suggestionsFocus?.traversalDescendants
      .where(
        (node) =>
            node is! FocusScopeNode &&
            node.canRequestFocus &&
            !node.rect.isEmpty,
      )
      .fold<FocusNode?>(
        null,
        (first, node) => switch (first) {
          final first? when first.rect.top <= node.rect.top => first,
          _ => node,
        },
      );

  KeyEventResult _enterSuggestions(FocusNode suggestion) {
    suggestion.requestFocus();
    return KeyEventResult.handled;
  }

  KeyEventResult _stopEditing({TraversalDirection? then}) {
    _barNode.requestFocus();
    if (then != null) _barNode.focusInDirection(then);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textField = KurumiTextField(
      focusNode: _fieldNode,
      cursorHeight: widget.cursorHeight,
      keyboardType: TextInputType.text,
      autocorrect: false,
      onTapOutside: (event) {
        if (widget.onTapOutside == null) {
          _fieldNode.unfocus();
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

    final searchBar = ListenableBuilder(
      listenable: _barNode,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.brightness == Brightness.dark
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: _barNode.hasPrimaryFocus
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: child,
      ),
      child: GestureDetector(
        onTap: () => widget.onTap?.call(),
        child: Row(
          children: [
            const SizedBox(width: 4),
            widget.leading ?? const SizedBox(width: 8),
            const SizedBox(width: 4),
            Expanded(
              child: Actions(
                actions: {
                  ActivateIntent: CallbackAction<ActivateIntent>(
                    onInvoke: (_) => _activate(),
                  ),
                },
                child: Focus(
                  focusNode: _barNode,
                  canRequestFocus: widget.enabled || widget.onTap != null,
                  onKeyEvent: _handleKey,
                  child: searchField,
                ),
              ),
            ),
            widget.trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );

    return switch (widget.suggestionsFocus) {
      final suggestions? => ListenableBuilder(
        listenable: Listenable.merge([_fieldNode, suggestions]),
        builder: (context, child) => PopScope(
          canPop: !_fieldNode.hasFocus && !suggestions.hasFocus,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _barNode.requestFocus();
          },
          child: child!,
        ),
        child: searchBar,
      ),
      null => searchBar,
    };
  }
}
