// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../post/types.dart';
import 'post_grid_controller.dart';

class PostControllerEventListener<T extends Post> extends StatefulWidget {
  const PostControllerEventListener({
    required this.controller,
    required this.child,
    super.key,
    this.onEvent,
  });

  final PostGridController<T> controller;
  final Widget child;
  final void Function(PostControllerEvent event)? onEvent;

  @override
  State<PostControllerEventListener<T>> createState() =>
      _PostControllerEventListenerState<T>();
}

class _PostControllerEventListenerState<T extends Post>
    extends State<PostControllerEventListener<T>> {
  late final Stream<PostControllerEvent> _events;
  late StreamSubscription<PostControllerEvent> _subscription;

  @override
  void initState() {
    super.initState();
    _events = widget.controller.events;
    _subscription = _events.listen(_handleEvent);
  }

  void _handleEvent(PostControllerEvent event) {
    if (mounted) {
      widget.onEvent?.call(event);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
