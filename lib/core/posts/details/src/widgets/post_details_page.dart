// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../router.dart';
import '../../../post/post.dart';
import '../../routes.dart';

class CurrentPostDetailsPage<T extends Post> extends ConsumerWidget {
  const CurrentPostDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = InheritedDetailsContext.of<T>(context);
    final booruBuilder = ref.watch(booruBuilderProvider(ref.watchConfigAuth));
    final builder = booruBuilder?.postDetailsPageBuilder;

    return builder != null
        ? builder(context, payload)
        : const UnimplementedPage();
  }
}

class PayloadPostDetailsPage<T extends Post> extends ConsumerWidget {
  const PayloadPostDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = InheritedDetailsContext.of<T>(context);
    final configSearch = payload.configSearch;

    if (configSearch == null) {
      return const UnimplementedPage();
    }

    final booruBuilder = ref.watch(booruBuilderProvider(configSearch.auth));
    final builder = booruBuilder?.postDetailsPageBuilder;

    return builder != null
        ? builder(context, payload)
        : const UnimplementedPage();
  }
}

class InheritedDetailsContext<T extends Post> extends InheritedWidget {
  const InheritedDetailsContext({
    required this.context,
    required super.child,
    super.key,
  });

  final DetailsRouteContext<T> context;

  static DetailsRouteContext<T> of<T extends Post>(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<InheritedDetailsContext<T>>();

    return widget?.context ??
        (throw Exception('No InheritedDetailsContext found in context'));
  }

  @override
  bool updateShouldNotify(InheritedDetailsContext<T> oldWidget) {
    return context != oldWidget.context;
  }
}
