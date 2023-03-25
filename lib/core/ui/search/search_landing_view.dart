// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/search_history.dart';
import 'package:boorusama/core/domain/searches/search_history.dart';
import 'package:boorusama/core/ui/search/favorite_tags/favorite_tags_section.dart';
import 'package:boorusama/core/ui/search/search_history_section.dart';

class SearchLandingView extends StatefulWidget {
  const SearchLandingView({
    super.key,
    required this.onHistoryTap,
    required this.onTagTap,
    required this.onHistoryRemoved,
    required this.onHistoryCleared,
    required this.onFullHistoryRequested,
    required this.metatagsBuilder,
    this.trendingBuilder,
    required this.onAddTagRequest,
  });

  final ValueChanged<String> onHistoryTap;
  final ValueChanged<SearchHistory> onHistoryRemoved;
  final VoidCallback onFullHistoryRequested;
  final VoidCallback onHistoryCleared;
  final ValueChanged<String> onTagTap;
  final Widget Function(BuildContext context) metatagsBuilder;
  final Widget Function(BuildContext context)? trendingBuilder;
  final VoidCallback onAddTagRequest;

  @override
  State<SearchLandingView> createState() => _SearchLandingViewState();
}

class _SearchLandingViewState extends State<SearchLandingView>
    with TickerProviderStateMixin {
  late final animationController = AnimationController(
    vsync: this,
    duration: kThemeAnimationDuration,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          if (!mounted) return;
          animationController.forward();
        },
      );
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animationController,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.metatagsBuilder(context),
              const SizedBox(
                height: 10,
              ),
              const Divider(thickness: 1),
              FavoriteTagsSection(
                onAddTagRequest: () => widget.onAddTagRequest(),
                onTagTap: widget.onTagTap,
              ),
              if (widget.trendingBuilder != null) ...[
                widget.trendingBuilder!.call(context),
              ],
              BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
                builder: (context, state) {
                  return SearchHistorySection(
                    histories: state.histories,
                    onHistoryTap: (history) =>
                        widget.onHistoryTap.call(history),
                    onHistoryRemoved: (history) =>
                        widget.onHistoryRemoved.call(history),
                    onHistoryCleared: () => widget.onHistoryCleared.call(),
                    onFullHistoryRequested: widget.onFullHistoryRequested,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
