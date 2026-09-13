// Dart imports:
import 'dart:async';

// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

class SettingReveal extends InheritedWidget {
  const SettingReveal({
    required this.target,
    required super.child,
    this.request = 0,
    super.key,
  });

  final String? target;
  final int request;

  static SettingReveal? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingReveal>();

  @override
  bool updateShouldNotify(SettingReveal oldWidget) =>
      target != oldWidget.target || request != oldWidget.request;
}

class SettingAnchor extends StatefulWidget {
  const SettingAnchor({required this.id, required this.child, super.key});

  final String id;
  final Widget child;

  @override
  State<SettingAnchor> createState() => _SettingAnchorState();
}

class _SettingAnchorState extends State<SettingAnchor> {
  SettingReveal? _handled;
  Timer? _timer;
  var _highlight = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reveal = SettingReveal.maybeOf(context);
    if (reveal?.target != widget.id ||
        (_handled?.target == reveal?.target &&
            _handled?.request == reveal?.request)) {
      return;
    }
    _handled = reveal;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final reduceMotion =
          context.kurumiBehavior.reduceMotion ||
          MediaQuery.disableAnimationsOf(context);
      await Scrollable.ensureVisible(
        context,
        alignment: 0.2,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 250),
      );
      if (!mounted) return;
      setState(() => _highlight = true);
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _highlight = false);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (SettingReveal.maybeOf(context) == null) return widget.child;
    return Material(
      animationDuration:
          context.kurumiBehavior.reduceMotion ||
              MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      color: _highlight
          ? Kurumi.themeOf(context).colorScheme.surfaceContainerHighest
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: widget.child,
    );
  }
}
