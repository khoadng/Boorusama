// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/configs.dart';
import '../../routers/widgets/failsafe_page.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
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
