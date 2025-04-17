// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../router.dart';
import '../../../selected_tags/tag.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final builder = booruBuilder?.searchPageBuilder;

    final params = InheritedInitialSearchQuery.maybeOf(context)?.params ??
        const SearchParams();

    return builder != null
        ? builder(context, params)
        : const UnimplementedPage();
  }
}

class InheritedInitialSearchQuery extends InheritedWidget {
  const InheritedInitialSearchQuery({
    required this.params,
    required super.child,
    super.key,
  });

  final SearchParams params;

  static InheritedInitialSearchQuery? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedInitialSearchQuery>();
  }

  static InheritedInitialSearchQuery? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedInitialSearchQuery>();
  }

  @override
  bool updateShouldNotify(InheritedInitialSearchQuery oldWidget) {
    return params != oldWidget.params;
  }
}

class SearchParams extends Equatable {
  const SearchParams({
    this.initialQuery,
    this.initialPage,
    this.initialScrollPosition,
    this.initialQueryType,
  });

  final String? initialQuery;
  final int? initialPage;
  final int? initialScrollPosition;
  final QueryType? initialQueryType;

  @override
  List<Object?> get props => [initialQuery, initialPage, initialScrollPosition];
}
