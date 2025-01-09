// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/routers/routes.dart';
import '../../../routers/widgets/failsafe_page.dart';
import '../post.dart';

class PostDetailsPage<T extends Post> extends ConsumerWidget {
  const PostDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = InheritedPayload.of<T>(context);
    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
    final builder = booruBuilder?.postDetailsPageBuilder;

    return builder != null
        ? builder(context, config, payload)
        : const UnimplementedPage();
  }
}

class InheritedPayload<T extends Post> extends InheritedWidget {
  const InheritedPayload({
    required this.payload,
    required super.child,
    super.key,
  });

  final DetailsPayload<T> payload;

  static DetailsPayload<T> of<T extends Post>(BuildContext context) {
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
