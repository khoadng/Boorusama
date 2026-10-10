import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui show InputDecorator;

import 'headless_app_harness.dart';

/// Logical size of a 1080p TV at 2x density, which renders the wide layout.
const kTvViewport = Size(960, 540);

/// Logical size of a common laptop window.
const kDesktopViewport = Size(1280, 800);

/// Drives the app the way a D-pad remote does, with arrows, select and back,
/// or the way a hardware keyboard does with Tab.
final class KeyboardFlowDriver {
  const KeyboardFlowDriver({
    required this.tester,
    required this.harness,
  });

  final WidgetTester tester;
  final HeadlessAppHarness harness;

  FocusNode? get focusedNode => FocusManager.instance.primaryFocus;

  bool isFocusWithin(Finder finder) => switch (focusedNode?.context) {
    final Element focused => finder.evaluate().any(
      (target) => target == focused || _isAncestor(target, focused),
    ),
    _ => false,
  };

  Future<void> press(LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await harness.settle(tester);
  }

  Future<void> arrow(TraversalDirection direction) =>
      press(_arrowFor(direction));

  Future<void> select() => press(LogicalKeyboardKey.select);

  Future<void> tab({bool backward = false}) async {
    if (backward) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    if (backward) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await harness.settle(tester);
  }

  /// Presses Tab until focus comes back around to a control it already
  /// visited, returning the controls in the order Tab visited them. Each
  /// stop is described as it lands, since lazy lists dispose controls once
  /// they scroll away.
  Future<List<TabStop>> tabCycle({
    bool backward = false,
    int maxPresses = 200,
  }) async {
    final screen = _topRouteScope();
    final stops = <TabStop>[];
    for (var i = 0; i < maxPresses; i++) {
      await tab(backward: backward);
      final node = focusedNode;
      if (node == null || stops.any((stop) => stop.node == node)) return stops;
      stops.add(
        TabStop(
          node: node,
          name: describeNode(node),
          place: _placeInList(node),
          onScreen: node.ancestors.contains(screen),
          inView: _isVisible(node),
          radioGroup: _radioGroupOf(node),
        ),
      );
    }
    throw TestFailure(
      'Tab never came back around after $maxPresses presses.\nVisited:\n  '
      '${stops.map((stop) => stop.name).join('\n  ')}',
    );
  }

  /// The remote's back button reaches Flutter as a system pop.
  Future<void> back() async {
    await tester.binding.handlePopRoute();
    await harness.settle(tester);
  }

  /// Presses [direction] until focus lands inside [target], failing with the
  /// focus trail when focus stops moving or never arrives.
  Future<void> moveFocusTo(
    Finder target,
    TraversalDirection direction, {
    int maxPresses = 12,
  }) async {
    final trail = [describeFocus()];
    for (var i = 0; i < maxPresses && !isFocusWithin(target); i++) {
      final before = focusedNode;
      await arrow(direction);
      trail.add(describeFocus());
      if (!isFocusWithin(target) && identical(before, focusedNode)) {
        throw TestFailure(
          'Focus is stuck pressing ${direction.name} while looking for '
          '${_describeFinder(target)}.\nTrail:\n  ${trail.join('\n  ')}',
        );
      }
    }

    if (!isFocusWithin(target)) {
      throw TestFailure(
        'Focus never reached ${_describeFinder(target)} after $maxPresses '
        '${direction.name} presses.\nTrail:\n  ${trail.join('\n  ')}',
      );
    }
  }

  /// Finds the shortest arrow sequence from the current focus to [target]
  /// and replays it, so the target is proven reachable with keys alone.
  Future<void> navigateTo(Finder target) async {
    if (isFocusWithin(target)) return;

    final start = focusedNode;
    final map = await _explore();
    final destination = map.paths.keys
        .where((node) => isNodeWithin(node, target))
        .firstOrNull;
    if (start != null) await _jumpTo(start);

    final path = map.paths[destination];
    if (path == null) {
      throw TestFailure(
        'No arrow path from ${describeFocus()} reaches '
        '${_describeFinder(target)}.\nReachable:\n  '
        '${map.paths.keys.map(describeNode).join('\n  ')}',
      );
    }

    for (final direction in path) {
      await arrow(direction);
    }
    expect(
      isFocusWithin(target),
      isTrue,
      reason:
          'Replaying ${path.map((d) => d.name)} ended on ${describeFocus()} '
          'instead of ${_describeFinder(target)}',
    );
  }

  /// Focuses [target] directly, for restoring a known starting point between
  /// walks once [navigateTo] has proven the target reachable.
  Future<void> focusOn(Finder target) async {
    final node = _topRouteScope().traversalDescendants
        .where((node) => isNodeWithin(node, target))
        .firstOrNull;
    if (node == null) {
      throw TestFailure('Nothing focusable in ${_describeFinder(target)}');
    }
    await _jumpTo(node);
  }

  /// Ways a remote user gets stuck on the top screen, starting from the
  /// current focus: controls no arrow path reaches, controls no arrow leaves,
  /// and arrows that send focus somewhere invisible.
  Future<List<String>> focusProblems() async {
    final start = focusedNode;
    final targets = focusTargets();
    final map = await _explore();
    if (start != null) await _jumpTo(start);

    return [
      for (final (:from, :direction, :to) in map.invisibleLandings)
        'pressing ${direction.name} on ${describeNode(from)} moves focus to '
            'invisible ${describeNode(to)}',
      // A screen with a single control has nowhere else to go.
      if (map.paths.keys.where((node) => node is! FocusScopeNode).length > 1)
        for (final node in map.deadEnds)
          'no arrow leaves ${describeNode(node)}',
      for (final node in targets)
        if (!map.paths.containsKey(node) && (node.context?.mounted ?? false))
          'no arrow path reaches ${describeNode(node)}',
    ];
  }

  /// Ways Tab misbehaves on the top screen, both ways around from the
  /// current focus: controls Tab never reaches, and Tab landing on a control
  /// out of view or off the top screen. Controls are told apart by their
  /// position in scrolled content, since lazy lists rebuild them.
  Future<List<String>> tabProblems() async {
    final start = focusedNode;
    final targets = {
      for (final node in focusTargets())
        if (node is! FocusScopeNode)
          _placeInList(node): (
            name: describeNode(node),
            radioGroup: _radioGroupOf(node),
          ),
    };

    final problems = <String>[];
    for (final backward in [false, true]) {
      if (start != null) await _jumpTo(start);
      final key = backward ? 'Shift+Tab' : 'Tab';
      final stops = await tabCycle(backward: backward);
      final reached = {for (final stop in stops) stop.place};
      // A radio group takes a single Tab stop, on its selected option.
      final reachedGroups = {for (final stop in stops) ?stop.radioGroup};
      problems.addAll([
        for (final stop in stops)
          if (!stop.onScreen)
            '$key leaves the screen for ${stop.name}'
          else if (!stop.inView)
            '$key lands out of view on ${stop.name}',
        for (final MapEntry(key: rect, value: (:name, :radioGroup))
            in targets.entries)
          if (!reached.contains(rect) && !reachedGroups.contains(radioGroup))
            'no $key reaches $name',
      ]);
    }

    if (start != null) await _jumpTo(start);
    return problems;
  }

  /// Controls on the top screen, or in the focus scope around [within],
  /// whose focused look is too close to their unfocused look to spot from
  /// across a room. A highlight counts when it changes at least the area of a
  /// 2px outline at 3:1 contrast (WCAG 2.4.13).
  Future<List<String>> faintFocus({Finder? within}) async {
    final start = focusedNode;
    final strategy = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    // The focus ring stays hidden until the user has touched the keyboard.
    await tester.sendKeyEvent(LogicalKeyboardKey.shift);

    final problems = <String>[];
    try {
      for (final node in focusTargets(within: within)) {
        if (node is FocusScopeNode) continue;
        await _jumpTo(node);
        // Skipping silently would let a surface that closes mid-check pass.
        if (!node.hasPrimaryFocus) {
          problems.add('could not focus ${describeNode(node)} to check it');
          continue;
        }
        if (!_isVisible(node)) continue;
        await harness.settle(tester);
        final rect = _highlightArea(node);
        final focused = await _capture();

        node.unfocus();
        await harness.settle(tester);
        final unfocused = await _capture();

        final ratio = tester.view.devicePixelRatio;
        // Rounded corners blend some edge pixels below 3:1, so a full 2px
        // outline can fall a little short of its rectangle's area.
        final outline =
            0.95 * 2 * 2 * (rect.width + rect.height) * ratio * ratio;
        // A highlight may sit just outside the control, like a focus ring.
        final changed = _contrastingPixels(
          focused,
          unfocused,
          rect.inflate(6),
        );
        if (changed < outline) {
          problems.add(
            'focus on ${describeNode(node)} changes $changed px at 3:1 '
            'contrast, needs ${outline.round()}',
          );
        }
      }
    } finally {
      FocusManager.instance.highlightStrategy = strategy;
      if (start != null) await _jumpTo(start);
    }
    return problems;
  }

  /// Reading pixels needs the real event loop, so only the read runs there.
  Future<_Frame> _capture() async {
    final layer = tester.binding.renderViews.first.debugLayer! as OffsetLayer;
    final image = layer.toImageSync(Offset.zero & tester.view.physicalSize);
    try {
      final bytes = await tester.runAsync(image.toByteData);
      return _Frame(bytes!.buffer.asUint32List(), image.width, image.height);
    } finally {
      image.dispose();
    }
  }

  int _contrastingPixels(_Frame a, _Frame b, Rect logicalRegion) {
    final ratio = tester.view.devicePixelRatio;
    final region = (logicalRegion.topLeft * ratio & logicalRegion.size * ratio)
        .intersect(Offset.zero & Size(a.width.toDouble(), a.height.toDouble()));
    if (region.isEmpty) return 0;

    var count = 0;
    for (var y = region.top.floor(); y < region.bottom.ceil(); y++) {
      for (var x = region.left.floor(); x < region.right.ceil(); x++) {
        final i = y * a.width + x;
        if (a.pixels[i] == b.pixels[i]) continue;
        final (la, lb) = (_luminance(a.pixels[i]), _luminance(b.pixels[i]));
        final (hi, lo) = la > lb ? (la, lb) : (lb, la);
        if ((hi + 0.05) / (lo + 0.05) >= 3) count++;
      }
    }
    return count;
  }

  /// Relative luminance of a little-endian RGBA pixel.
  static double _luminance(int rgba) =>
      0.2126 * _linear[rgba & 0xff] +
      0.7152 * _linear[(rgba >> 8) & 0xff] +
      0.0722 * _linear[(rgba >> 16) & 0xff];

  static final _linear = List<double>.generate(256, (i) {
    final c = i / 255;
    return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
  }, growable: false);

  /// Controls on a surface that closes once focus leaves it, such as a
  /// popover, that no arrow path from the current focus reaches without
  /// leaving it. [reopen] restores the starting focus after an arrow closes
  /// the surface. Controls are told apart by their position in scrolled
  /// content, since reopening rebuilds them and revealing one scrolls it.
  Future<List<String>> unreachableIn(
    Finder surface, {
    required Future<void> Function() reopen,
  }) async {
    final targets = {
      for (final node in focusTargets(within: surface))
        if (node is! FocusScopeNode) _contentRect(node): describeNode(node),
    };
    final start = switch (focusedNode) {
      final node? => _contentRect(node),
      null => null,
    };
    if (start == null) {
      return ['nothing is focused on ${_describeFinder(surface)}'];
    }

    final paths = {start: const <TraversalDirection>[]};
    final pending = Queue.of([start]);
    while (pending.isNotEmpty) {
      final from = pending.removeFirst();
      for (final direction in TraversalDirection.values) {
        await reopen();
        for (final step in paths[from]!) {
          await arrow(step);
        }
        await arrow(direction);

        final to = switch (focusedNode) {
          final node? => _contentRect(node),
          null => null,
        };
        if (to == null || !isFocusWithin(surface)) continue;
        if (paths.containsKey(to)) continue;
        paths[to] = [...paths[from]!, direction];
        pending.add(to);
      }
    }
    await reopen();

    return [
      for (final MapEntry(key: rect, value: name) in targets.entries)
        if (!paths.containsKey(rect)) 'no arrow path reaches $name',
    ];
  }

  /// Traversable focus targets in the focus scope of [within], or on the top
  /// screen. Controls scrolled off-screen count, since arrows should scroll
  /// them into view.
  List<FocusNode> focusTargets({Finder? within}) =>
      switch (within) {
            final within? => _scopeOf(within),
            null => _topRouteScope(),
          }.traversalDescendants
          .where(
            (node) =>
                node.canRequestFocus &&
                node.context != null &&
                !node.rect.isEmpty,
          )
          .toList(growable: false);

  /// Where [node] sits in the content of its nearest scroll view, which stays
  /// the same however far that is scrolled, and wherever the scroll view
  /// itself moves on screen.
  static ListPlace _placeInList(FocusNode node) {
    final context = node.context;
    final list = switch (context) {
      final context? => Scrollable.maybeOf(context),
      null => null,
    };
    final box = list?.context.findRenderObject();
    if (list == null || box is! RenderBox || !box.hasSize) {
      return (list: null, rect: node.rect);
    }

    final pixels = list.position.pixels;
    final local = node.rect.shift(-box.localToGlobal(Offset.zero));
    return (
      list: list.context as Element,
      rect: local.shift(switch (list.axisDirection) {
        AxisDirection.down => Offset(0, pixels),
        AxisDirection.up => Offset(0, -pixels),
        AxisDirection.right => Offset(pixels, 0),
        AxisDirection.left => Offset(-pixels, 0),
      }),
    );
  }

  /// [node]'s rect with every scroll view around it scrolled back to the
  /// start, so it stays the same however far the content is scrolled.
  static Rect _contentRect(FocusNode node) {
    var rect = node.rect;
    final context = node.context;
    if (context == null) return rect;

    for (
      var scrollable = Scrollable.maybeOf(context);
      scrollable != null;
      scrollable = Scrollable.maybeOf(scrollable.context)
    ) {
      final pixels = scrollable.position.pixels;
      rect = rect.shift(switch (scrollable.axisDirection) {
        AxisDirection.down => Offset(0, pixels),
        AxisDirection.up => Offset(0, -pixels),
        AxisDirection.right => Offset(pixels, 0),
        AxisDirection.left => Offset(-pixels, 0),
      });
    }
    return rect;
  }

  /// The focus scope around [surface], or the scope it is itself.
  FocusScopeNode _scopeOf(Finder surface) {
    final element = tester.element(surface.first);
    return switch (element.widget) {
      FocusScope(focusNode: final FocusScopeNode node) => node,
      _ => FocusScope.of(element),
    };
  }

  /// Breadth-first walk over arrow presses. Each visited node is re-focused
  /// directly before every press, so the walk does not depend on press order,
  /// but every edge is still a real key event that shortcuts may intercept.
  Future<_FocusMap> _explore() async {
    final start = focusedNode;
    final paths = <FocusNode, List<TraversalDirection>>{};
    final invisibleLandings =
        <({FocusNode from, TraversalDirection direction, FocusNode to})>[];
    final deadEnds = <FocusNode>[];
    if (start == null) return _FocusMap(paths, invisibleLandings, deadEnds);

    paths[start] = const [];
    final pending = Queue.of([start]);
    while (pending.isNotEmpty) {
      final from = pending.removeFirst();
      var exits = 0;
      for (final direction in TraversalDirection.values) {
        if (from.context == null) break;
        await _jumpTo(from);
        await arrow(direction);

        final to = focusedNode;
        if (to == null || to.context == null || identical(to, from)) continue;
        if (!_isVisible(to)) {
          invisibleLandings.add((from: from, direction: direction, to: to));
          continue;
        }
        exits++;
        if (paths.containsKey(to)) continue;
        paths[to] = [...paths[from]!, direction];
        pending.add(to);
      }
      if (exits == 0 && from is! FocusScopeNode && from.context != null) {
        deadEnds.add(from);
      }
    }

    return _FocusMap(paths, invisibleLandings, deadEnds);
  }

  /// Moves focus straight to [node] and clears the directional history, so
  /// the next arrow behaves as if the user had arrived there by key. A scope
  /// stands for "nothing focused inside it yet".
  Future<void> _jumpTo(FocusNode node) async {
    node.requestFocus();
    await tester.pump();

    switch (node) {
      case FocusScopeNode() when focusedNode != node:
        focusedNode?.unfocus();
        await tester.pump();
      case FocusScopeNode():
        break;
      case FocusNode(:final context?) when context.mounted && node.hasFocus:
        await Scrollable.ensureVisible(context);
        await tester.pump();
      case FocusNode():
        break;
    }

    if ((node.context, node.nearestScope) case (final context?, final scope?)) {
      FocusTraversalGroup.maybeOf(context)?.invalidateScopeData(scope);
    }
  }

  static Element? _radioGroupOf(FocusNode node) {
    Element? group;
    node.context?.visitAncestorElements((element) {
      if (element.widget is RadioGroup) group = element;
      return group == null;
    });
    return group;
  }

  bool _isVisible(FocusNode node) {
    if (!node.canRequestFocus || node.context == null) return false;
    final screen =
        Offset.zero & tester.view.physicalSize / tester.view.devicePixelRatio;
    final rect = node.rect;
    return !rect.isEmpty && screen.overlaps(rect);
  }

  // A text field shows focus on its decoration, which surrounds the editable
  // text by its padding.
  Rect _highlightArea(FocusNode node) {
    final context = node.context;
    if (context?.findAncestorWidgetOfExactType<EditableText>() == null) {
      return node.rect;
    }
    return switch (_decoratorBox(context!)) {
      final box? => box.localToGlobal(Offset.zero) & box.size,
      null => node.rect,
    };
  }

  RenderBox? _decoratorBox(BuildContext context) {
    RenderBox? box;
    context.visitAncestorElements((element) {
      if (element.widget is! mui.InputDecorator) return true;
      box = element.renderObject as RenderBox?;
      return false;
    });
    return box;
  }

  bool isNodeWithin(FocusNode node, Finder finder) => switch (node.context) {
    final Element element => finder.evaluate().any(
      (target) => target == element || _isAncestor(target, element),
    ),
    _ => false,
  };

  String describeFocus() => switch (focusedNode) {
    final FocusNode node => describeNode(node),
    null => '<nothing focused>',
  };

  String describeNode(FocusNode node) {
    final context = node.context;
    if (context is! Element || !context.mounted) return node.toStringShort();

    final label = _labelOf(context);
    final rect = node.rect;
    final position =
        '(${rect.left.round()},${rect.top.round()} '
        '${rect.width.round()}x${rect.height.round()})';
    return '${_ownerOf(context)}${label == null ? '' : ' "$label"'} $position';
  }

  /// Names a control after its nearest interactive-looking ancestor, falling
  /// back to the raw focus widget.
  String _ownerOf(Element element) {
    String? owner;
    var depth = 0;
    element.visitAncestorElements((ancestor) {
      final name = ancestor.widget.runtimeType.toString().split('<').first;
      if (!name.startsWith('_') && _interactiveSuffixes.any(name.endsWith)) {
        owner = name;
      }
      return owner == null && ++depth < 30;
    });
    return owner ?? element.widget.runtimeType.toString();
  }

  String? _labelOf(Element element) {
    String? label;
    void visit(Element child) {
      if (label != null) return;
      label = switch (child.widget) {
        Tooltip(:final message?) => message,
        Text(:final data?) when data.trim().isNotEmpty => data,
        Icon(:final semanticLabel?) => semanticLabel,
        Icon(:final icon?) => 'icon 0x${icon.codePoint.toRadixString(16)}',
        _ => null,
      };
      if (label == null) child.visitChildElements(visit);
    }

    element.visitAncestorElements((ancestor) {
      if (ancestor.widget case Tooltip(:final message?)) label = message;
      return label == null && ancestor.widget is! Focus;
    });
    if (label == null) element.visitChildElements(visit);
    return label;
  }

  static String _describeFinder(Finder finder) =>
      finder.toString(describeSelf: true);

  FocusScopeNode _topRouteScope() {
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    final navigatorScope = navigator.focusNode.enclosingScope;
    return navigator.focusNode.descendants
        .whereType<FocusScopeNode>()
        .lastWhere(
          (scope) =>
              scope.enclosingScope == navigatorScope && !scope.skipTraversal,
        );
  }

  static bool _isAncestor(Element ancestor, Element descendant) {
    var found = false;
    descendant.visitAncestorElements((element) {
      found = identical(element, ancestor);
      return !found;
    });
    return found;
  }

  static LogicalKeyboardKey _arrowFor(TraversalDirection direction) =>
      switch (direction) {
        TraversalDirection.up => LogicalKeyboardKey.arrowUp,
        TraversalDirection.down => LogicalKeyboardKey.arrowDown,
        TraversalDirection.left => LogicalKeyboardKey.arrowLeft,
        TraversalDirection.right => LogicalKeyboardKey.arrowRight,
      };

  static const _interactiveSuffixes = [
    'Button',
    'Tile',
    'Item',
    'Field',
    'Searchbar',
    'SearchBar',
    'Chip',
    'Switch',
    'Checkbox',
    'Slider',
    'Tab',
  ];
}

/// A control's scroll view and its rect in that scroll view's content.
typedef ListPlace = ({Element? list, Rect rect});

/// A control Tab landed on, described when it did.
final class TabStop {
  const TabStop({
    required this.node,
    required this.name,
    required this.place,
    required this.onScreen,
    required this.inView,
    required this.radioGroup,
  });

  final FocusNode node;
  final String name;

  final ListPlace place;

  /// Whether the control belongs to the top screen.
  final bool onScreen;
  final bool inView;
  final Element? radioGroup;
}

final class _FocusMap {
  const _FocusMap(this.paths, this.invisibleLandings, this.deadEnds);

  /// Shortest arrow sequence from the starting focus to each reached node.
  final Map<FocusNode, List<TraversalDirection>> paths;
  final List<({FocusNode from, TraversalDirection direction, FocusNode to})>
  invisibleLandings;

  /// Visited nodes that no arrow moves focus away from.
  final List<FocusNode> deadEnds;
}

final class _Frame {
  const _Frame(this.pixels, this.width, this.height);

  final Uint32List pixels;
  final int width;
  final int height;
}
