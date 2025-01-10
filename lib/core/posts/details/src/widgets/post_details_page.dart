// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../router.dart';
import '../../../post/post.dart';
import '../../routes.dart';

class PostDetailsPage<T extends Post> extends ConsumerWidget {
  const PostDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = InheritedPayload.of<T>(context);
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final builder = booruBuilder?.postDetailsPageBuilder;

    return builder != null
        ? builder(context, payload)
        : const UnimplementedPage();
  }
}

class InheritedPayload<T extends Post> extends InheritedWidget {
  const InheritedPayload({
    required this.payload,
    required super.child,
    super.key,
  });

  final DetailsRoutePayload<T> payload;

  static DetailsRoutePayload<T> of<T extends Post>(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<InheritedPayload<T>>();

    return widget?.payload ??
        (throw Exception('No InheritedPayload found in context'));
  }

  @override
  bool updateShouldNotify(InheritedPayload<T> oldWidget) {
    return payload != oldWidget.payload;
  }
}
