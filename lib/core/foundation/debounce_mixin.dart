// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

mixin DebounceMixin {
  final Map<String, Timer> _timers = {};

  void debounce<T>(
    String key,
    Function function, {
    Duration duration = const Duration(milliseconds: 350),
  }) {
    if (_timers.containsKey(key)) {
      _timers[key]?.cancel();
    }

    _timers[key] = Timer(
      duration,
      () {
        function();
        _timers.remove(key);
      },
    );
  }
}

class DebounceText extends StatefulWidget {
  const DebounceText({
    super.key,
    required this.controller,
    required this.builder,
    required this.debounceKey,
  });

  final String debounceKey;
  final TextEditingController controller;
  final Widget Function(BuildContext context, String text) builder;

  @override
  State<DebounceText> createState() => _DebounceTextState();
}

class _DebounceTextState extends State<DebounceText> with DebounceMixin {
  late var text = widget.controller.text;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    debounce(
      widget.debounceKey,
      () {
        if (mounted) {
          setState(() {
            text = widget.controller.text;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, text);
  }
}
