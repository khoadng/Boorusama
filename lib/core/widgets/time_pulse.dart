// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

class TimePulse extends StatefulWidget {
  const TimePulse({
    required this.initial,
    required this.updateInterval,
    required this.builder,
    super.key,
  });

  final DateTime initial;
  final Duration updateInterval;
  final Widget Function(BuildContext context, DateTime date) builder;

  @override
  State<TimePulse> createState() => _TimePulseState();
}

class _TimePulseState extends State<TimePulse> {
  late Timer _timer;
  late DateTime _currentTime;
  late DateTime _baseTime;

  @override
  void initState() {
    super.initState();
    _baseTime = widget.initial;
    _currentTime = _baseTime;
    _startTimer();
  }

  @override
  void didUpdateWidget(TimePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial ||
        oldWidget.updateInterval != widget.updateInterval) {
      _timer.cancel();
      _baseTime = widget.initial;
      _currentTime = _baseTime;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(widget.updateInterval, (_) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentTime);
  }
}
