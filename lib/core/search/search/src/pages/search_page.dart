// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../router.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final builder = booruBuilder?.searchPageBuilder;

    final query = InheritedInitialSearchQuery.of(context)?.query;

    return builder != null
        ? builder(context, query)
        : const UnimplementedPage();
  }
}

class InheritedInitialSearchQuery extends InheritedWidget {
  const InheritedInitialSearchQuery({
    required this.query,
    required super.child,
    super.key,
  });

  final String? query;

  static InheritedInitialSearchQuery? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedInitialSearchQuery>();
  }

  @override
  bool updateShouldNotify(InheritedInitialSearchQuery oldWidget) {
    return query != oldWidget.query;
  }
}
