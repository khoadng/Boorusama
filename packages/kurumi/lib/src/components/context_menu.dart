import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../accessibility/behavior.dart';
import '../foundation/platform.dart';
import '../theme/theme.dart';
import 'focus_ring.dart';
import 'back_handler.dart';

/// Opens [menuItemsBuilder] on right-click or long-press anywhere in
/// [child], or from the keyboard with the menu key or Shift+F10 while focus is
/// inside it.
///
/// Only one context menu is open at a time, and the back button or Escape
/// closes it before doing anything else.
class KurumiContextMenu extends StatefulWidget {
  const KurumiContextMenu({
    required this.child,
    required this.menuItemsBuilder,
    super.key,
    this.controller,
    this.triggers = true,
  });

  /// Keys that open the menu of the focused control.
  static const keyboardTriggers = [
    SingleActivator(LogicalKeyboardKey.contextMenu),
    SingleActivator(LogicalKeyboardKey.f10, shift: true),
  ];

  final Widget child;
  final List<Widget> Function(BuildContext context) menuItemsBuilder;
  final KurumiContextMenuController? controller;

  /// Whether right-click, long-press and [keyboardTriggers] open the menu.
  /// Turn them off to open it only through [controller], such as for a menu
  /// shared by the items of a list that also drags them.
  final bool triggers;

  @override
  State<KurumiContextMenu> createState() => _KurumiContextMenuState();
}

class _KurumiContextMenuState extends State<KurumiContextMenu> {
  static _KurumiContextMenuState? _open;
  static final _mounted = <_KurumiContextMenuState>{};

  final _controller = AnchorContextMenuController();
  final _menuScope = FocusScopeNode(debugLabel: 'KurumiContextMenu');
  FocusNode? _returnFocus;
  var _openedByKeyboard = false;

  @override
  void initState() {
    super.initState();
    _mounted.add(this);
    widget.controller?._menu = this;
  }

  @override
  void didUpdateWidget(KurumiContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    if (oldWidget.controller?._menu == this) oldWidget.controller?._menu = null;
    widget.controller?._menu = this;
  }

  @override
  void dispose() {
    if (widget.controller?._menu == this) widget.controller?._menu = null;
    _mounted.remove(this);
    if (_open == this) _open = null;
    _controller.dispose();
    _menuScope.dispose();
    super.dispose();
  }

  void _show(Offset position, {required bool byKeyboard}) {
    if (_open case final open? when open != this) open._controller.hide();
    _open = this;
    _returnFocus = FocusManager.instance.primaryFocus;
    _openedByKeyboard = byKeyboard;
    _controller.show(position);
  }

  // The open menu's backdrop takes the right-click, so the menu under the
  // pointer is found here, the innermost one when menus are nested.
  void _switchTo(Offset position) {
    final target = _mounted
        .map((menu) => (menu: menu, area: menu._areaAt(position)))
        .where((hit) => hit.area != null)
        .fold<({_KurumiContextMenuState menu, double? area})?>(
          null,
          (best, hit) => switch (best) {
            final best? when best.area! <= hit.area! => best,
            _ => hit,
          },
        );
    _controller.hide();
    target?.menu._show(position, byKeyboard: false);
  }

  double? _areaAt(Offset position) => switch (context.findRenderObject()) {
    final RenderBox box
        when box.hasSize &&
            (Offset.zero & box.size).contains(box.globalToLocal(position)) =>
      box.size.width * box.size.height,
    _ => null,
  };

  void _showForFocus() {
    final rect = FocusManager.instance.primaryFocus?.rect;
    if (rect == null) return;
    _show(rect.bottomLeft, byKeyboard: true);
  }

  // Keyboard users land on the first item; pointer users get arrows and
  // Escape without a highlighted item they did not ask for.
  void _handleShow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.isShowing) return;
      final first = _menuScope.traversalDescendants.firstOrNull;
      if (_openedByKeyboard && first != null) {
        first.requestFocus();
      } else {
        _menuScope.requestFocus();
      }
    });
  }

  void _handleDismiss() {
    if (_open == this) _open = null;
    if (_menuScope.hasFocus) _returnFocus?.requestFocus();
    _returnFocus = null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final behavior =
        KurumiTheme.maybeBehaviorOf(context) ?? const KurumiBehaviorData();

    return AnchorContextMenu(
      controller: _controller,
      viewPadding: const EdgeInsets.all(8),
      backdropBuilder: (context) => Listener(
        onPointerDown: (event) {
          if (event.buttons & kSecondaryButton != 0) _switchTo(event.position);
        },
        child: kurumiIsMobilePlatform()
            ? const SizedBox.expand()
            : Container(color: Colors.transparent),
      ),
      onShow: () {
        behavior.contextMenuShowFeedback?.call();
        _handleShow();
      },
      onDismiss: _handleDismiss,
      menuBuilder: (context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): _controller.hide,
        },
        child: FocusScope(
          node: _menuScope,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 4,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              boxShadow: kElevationToShadow[4],
              border: Border.all(
                color: colorScheme.outlineVariant,
              ),
            ),
            constraints: const BoxConstraints(
              maxWidth: 200,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.menuItemsBuilder(context),
            ),
          ),
        ),
      ),
      childBuilder: (context) => ListenableBuilder(
        listenable: _controller,
        builder: (context, child) => KurumiBackHandler(
          enabled: _controller.isShowing,
          onBack: _controller.hide,
          child: child!,
        ),
        child: switch (widget.triggers) {
          false => widget.child,
          true => CallbackShortcuts(
            bindings: {
              for (final trigger in KurumiContextMenu.keyboardTriggers)
                trigger: _showForFocus,
            },
            child: GestureDetector(
              onLongPressStart: (details) =>
                  _show(details.globalPosition, byKeyboard: false),
              onSecondaryTapDown: (details) =>
                  _show(details.globalPosition, byKeyboard: false),
              child: widget.child,
            ),
          ),
        },
      ),
    );
  }
}

/// Opens and closes a [KurumiContextMenu] from code.
class KurumiContextMenuController {
  _KurumiContextMenuState? _menu;

  /// Opens the menu at [position]. A menu opened [fromKeyboard] focuses its
  /// first item.
  void showAt(Offset position, {bool fromKeyboard = false}) =>
      _menu?._show(position, byKeyboard: fromKeyboard);

  void hide() => _menu?._controller.hide();
}

class KurumiContextMenuDivider extends StatelessWidget {
  const KurumiContextMenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      endIndent: 12,
      indent: 12,
      height: 8,
    );
  }
}

class KurumiContextMenuTile extends StatelessWidget {
  const KurumiContextMenuTile({
    required this.title,
    super.key,
    this.onTap,
    this.enabled = true,
    this.hideOnTap = true,
    this.destructive = false,
  });

  final String title;
  final VoidCallback? onTap;
  final bool enabled;
  final bool hideOnTap;

  /// Marks an action that deletes or discards something.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final behavior =
        KurumiTheme.maybeBehaviorOf(context) ?? const KurumiBehaviorData();

    void handleTap() {
      if (hideOnTap) {
        context.hideMenu();
      }

      behavior.contextMenuSelectionFeedback?.call();
      onTap?.call();
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        constraints: const BoxConstraints(
          minWidth: 200,
        ),
        child: Semantics(
          button: true,
          enabled: enabled,
          label: title,
          onTap: enabled ? handleTap : null,
          excludeSemantics: true,
          child: KurumiFocusHighlight(
            builder: (context, highlighted) => InkWell(
              hoverColor: enabled ? colorScheme.primary : Colors.transparent,
              focusColor: Colors.transparent,
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onTap: enabled ? handleTap : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: highlighted ? colorScheme.primary : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: switch ((enabled, destructive, highlighted)) {
                      (false, _, _) => colorScheme.onSurface.withValues(
                        alpha: 0.38,
                      ),
                      (true, _, true) => colorScheme.onPrimary,
                      (true, true, false) => colorScheme.error,
                      (true, false, false) => colorScheme.onSurface,
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
