import 'package:equatable/equatable.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

import '../accessibility/behavior.dart';
import '../theme/theme.dart';

class KurumiSegmentedButton<T> extends StatefulWidget {
  const KurumiSegmentedButton({
    required this.segments,
    required this.initialValue,
    required this.onChanged,
    super.key,
    this.fixedWidth,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
  });

  final T? initialValue;
  final Map<T, String> segments;
  final double? fixedWidth;
  final ValueChanged<T> onChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;

  @override
  State<KurumiSegmentedButton<T>> createState() =>
      _KurumiSegmentedButtonState<T>();
}

class _KurumiSegmentedButtonState<T> extends State<KurumiSegmentedButton<T>> {
  late var selected = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return KurumiSlidingSegmentedControl<T>(
      initialValue: selected,
      children: {
        for (final entry in widget.segments.entries)
          entry.key: Text(
            entry.value,
            style: selected == entry.key
                ? widget.selectedTextStyle ??
                      TextStyle(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimary,
                      )
                : widget.unselectedTextStyle ??
                      TextStyle(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
          ),
      },
      height: 32,
      fixedWidth: widget.fixedWidth,
      thumbDecoration: BoxDecoration(
        color: widget.selectedColor ?? colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      innerPadding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: widget.unselectedColor ?? colorScheme.surfaceContainerHighest,
      ),
      onValueChanged: (value) {
        setState(() {
          KurumiTheme.maybeBehaviorOf(
            context,
          )?.segmentedSelectionFeedback?.call();
          selected = value;
          widget.onChanged(value);
        });
      },
    );
  }
}

class KurumiSlidingSegmentedControl<T> extends StatefulWidget {
  const KurumiSlidingSegmentedControl({
    required this.children,
    required this.onValueChanged,
    super.key,
    this.initialValue,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.innerPadding = const EdgeInsets.all(2),
    this.padding = 12,
    this.fixedWidth,
    this.decoration = const BoxDecoration(color: CupertinoColors.systemGrey5),
    this.thumbDecoration = const BoxDecoration(color: Colors.white),
    this.clipBehavior = Clip.none,
    this.height = 40,
    this.onTapSegment,
  }) : assert(children.length != 0, 'children must not be empty');

  final Decoration? decoration;
  final Decoration? thumbDecoration;
  final Map<T, Widget> children;
  final ValueChanged<T> onValueChanged;
  final Duration duration;
  final Curve curve;
  final EdgeInsets innerPadding;
  final double padding;
  final double? fixedWidth;
  final T? initialValue;
  final Clip clipBehavior;
  final bool Function(T? segment)? onTapSegment;
  final double? height;

  @override
  State<KurumiSlidingSegmentedControl<T>> createState() =>
      _KurumiSlidingSegmentedControlState<T>();
}

class _KurumiSlidingSegmentedControlState<T>
    extends State<KurumiSlidingSegmentedControl<T>> {
  T? current;
  double? height;
  double offset = 0;
  Map<T?, double> sizes = {};
  var hasTouch = false;
  double? maxSize;
  List<KurumiSegmentCache<T>> cacheItems = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void didUpdateWidget(
    covariant KurumiSlidingSegmentedControl<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    final changeInitial = oldWidget.initialValue != widget.initialValue;
    final changeChildrenLength =
        oldWidget.children.length != widget.children.length;

    if (changeInitial || changeChildrenLength) {
      hasTouch = true;
      initialize(oldCurrent: current, isChangeInitial: changeInitial);
      for (final cache in cacheItems) {
        calculateSize(
          size: cache.size,
          item: cache.item,
          isCacheEnabled: false,
        );
      }
    }
  }

  void initialize({
    T? oldCurrent,
    bool isChangeInitial = false,
  }) {
    final List<T?> values = widget.children.keys.toList();
    final index = values.indexOf(widget.initialValue);
    final keys = values.toList();

    if (!isChangeInitial && oldCurrent != null) {
      current = oldCurrent;
    } else {
      if (widget.initialValue != null) {
        current = keys[index];
      } else {
        current = keys.first;
      }
    }
  }

  void calculateSize({
    required Size size,
    required MapEntry<T?, Widget> item,
    required bool isCacheEnabled,
  }) {
    height = size.height;
    final measuredSize = <T?, double>{}
      ..putIfAbsent(item.key, () => widget.fixedWidth ?? size.width);

    setState(() {
      if (isCacheEnabled) {
        cacheItems.add(KurumiSegmentCache<T>(item: item, size: size));
      }
      sizes = {...sizes, ...measuredSize};

      offset = kurumiComputeSegmentOffset<T>(
        current: current,
        items: widget.children.keys.toList(),
        sizes: sizes.values.toList(),
      );
    });
  }

  void onTapItem(MapEntry<T?, Widget> item) {
    if (widget.onTapSegment?.call(item.key) == false) {
      return;
    }

    if (!hasTouch) {
      setState(() => hasTouch = true);
    }
    setState(() => current = item.key);
    final List<T?> keys = widget.children.keys.toList();
    final computedOffset = kurumiComputeSegmentOffset<T>(
      current: current,
      items: keys,
      sizes: sizes.values.toList(),
    );
    setState(() => offset = computedOffset);
    final value = keys[keys.indexOf(current)] as T;
    widget.onValueChanged(value);
  }

  Widget _segmentItem(MapEntry<T, Widget> item) {
    return Semantics(
      button: true,
      selected: current == item.key,
      child: InkWell(
        onTap: () => onTapItem(item),
        child: Container(
          height: widget.height,
          width: maxSize ?? widget.fixedWidth,
          padding: EdgeInsets.symmetric(horizontal: widget.padding),
          child: Center(child: item.value),
        ),
      ),
    );
  }

  Widget layout() {
    return Container(
      clipBehavior: widget.clipBehavior,
      decoration: widget.decoration,
      padding: widget.innerPadding,
      child: Stack(
        children: [
          KurumiSegmentAnimationPanel<T>(
            hasTouch: hasTouch,
            offset: offset,
            height: height,
            width: sizes[current],
            duration: widget.duration,
            curve: widget.curve,
            decoration: widget.thumbDecoration,
          ),
          Row(
            children: widget.children.entries
                .map((item) {
                  return KurumiMeasureSize(
                    onChange: (value) {
                      calculateSize(
                        size: value,
                        item: item,
                        isCacheEnabled: true,
                      );
                    },
                    child: _segmentItem(item),
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [layout()],
        );
      },
    );
  }
}

class KurumiMeasureSize extends SingleChildRenderObjectWidget {
  const KurumiMeasureSize({
    required Widget super.child,
    required this.onChange,
    super.key,
  });

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _KurumiSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    (renderObject as _KurumiSizeRenderObject).onChange = onChange;
  }
}

class _KurumiSizeRenderObject extends RenderProxyBox {
  _KurumiSizeRenderObject(this.onChange);

  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (child == null) return;
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

double kurumiComputeSegmentOffset<T>({
  required List<double> sizes,
  required List<T?> items,
  T? current,
}) {
  if (sizes.isNotEmpty && sizes.length == items.length) {
    return sizes
        .getRange(0, items.indexOf(current))
        .fold<double>(0, (previousValue, element) => previousValue + element);
  } else {
    return 0;
  }
}

class KurumiSegmentCache<T> extends Equatable {
  const KurumiSegmentCache({
    required this.item,
    required this.size,
  });

  final MapEntry<T?, Widget> item;
  final Size size;

  @override
  List<Object?> get props => [item, size];
}

class KurumiSegmentAnimationPanel<T> extends StatelessWidget {
  const KurumiSegmentAnimationPanel({
    required this.offset,
    required this.width,
    required this.height,
    required this.hasTouch,
    required this.duration,
    required this.curve,
    super.key,
    this.decoration,
  });

  final double offset;
  final double? width;
  final double? height;
  final Duration duration;
  final Curve curve;
  final bool hasTouch;
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final effectiveOffset = isRtl ? offset * -1 : offset;
    final behavior =
        KurumiTheme.maybeBehaviorOf(context) ?? const KurumiBehaviorData();

    return AnimatedContainer(
      transform: Matrix4.translationValues(effectiveOffset, 0, 0),
      duration: !hasTouch
          ? Duration.zero
          : behavior.effectiveDuration(duration),
      curve: curve,
      width: width,
      decoration: decoration,
      height: height,
    );
  }
}
