// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n/i18n.dart';

class ResultCounter extends StatelessWidget {
  const ResultCounter({
    required this.count,
    required this.loading,
    super.key,
    this.onRefresh,
  });

  final bool loading;
  final int count;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Row(
        children: [
          Text(
            context.t.search.search_in_progress_notice,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 10),
          const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator.adaptive(),
          ),
        ],
      );
    }

    if (count > 0) {
      return Row(
        children: [
          Text(
            context.t.search.result_counter(n: count),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          if (onRefresh != null)
            _RotatingIcon(
              onPressed: onRefresh!,
            ),
        ],
      );
    } else {
      return Text(
        context.t.search.no_result_notice,
        style: Theme.of(context).textTheme.titleLarge,
      );
    }
  }
}

class _RotatingIcon extends StatefulWidget {
  const _RotatingIcon({
    required this.onPressed,
  });

  final Future<void> Function() onPressed;

  @override
  _RotatingIconState createState() => _RotatingIconState();
}

class _RotatingIconState extends State<_RotatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late bool _isWaiting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startRotation() {
    setState(() {
      _isWaiting = true;
      _controller.repeat();
    });
    widget.onPressed().whenComplete(() {
      setState(() {
        _isWaiting = false;
        _controller.reset();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: _isWaiting ? null : _startRotation,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: RotationTransition(
          // ignore: prefer_int_literals
          turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
          child: const Icon(
            FontAwesomeIcons.rotate,
            size: 14,
          ),
        ),
      ),
    );
  }
}
