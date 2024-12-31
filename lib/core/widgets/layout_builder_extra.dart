// Flutter imports:
import 'package:flutter/widgets.dart';

class WidthThresholdPopper extends StatefulWidget {
  const WidthThresholdPopper({
    required this.targetWidth,
    super.key,
    this.child,
  });

  final double targetWidth;
  final Widget? child;

  @override
  State<WidthThresholdPopper> createState() => _WidthThresholdPopperState();
}

class _WidthThresholdPopperState extends State<WidthThresholdPopper> {
  final _shouldPop = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _shouldPop.addListener(_onPop);
  }

  void _onPop() {
    if (_shouldPop.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreciseLayoutWidthListener(
      targetWidth: widget.targetWidth,
      onWidthChanged: () {
        _shouldPop.value = true;
      },
      child: widget.child ?? const SizedBox.shrink(),
    );
  }
}

class PreciseLayoutWidthListener extends StatelessWidget {
  const PreciseLayoutWidthListener({
    required this.child,
    required this.targetWidth,
    required this.onWidthChanged,
    super.key,
  });

  final Widget child;
  final double targetWidth;
  final void Function() onWidthChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= targetWidth) {
          onWidthChanged();
        }

        return child;
      },
    );
  }
}
