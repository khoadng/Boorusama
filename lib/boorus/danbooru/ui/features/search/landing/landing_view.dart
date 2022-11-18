// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/most_searched_tag_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'favorite_tags_section.dart';
import 'metatags_section.dart';
import 'search_history.dart';

class LandingView extends StatefulWidget {
  const LandingView({
    super.key,
    this.onOptionTap,
    this.onHistoryTap,
    this.onTagTap,
    this.onHistoryRemoved,
  });

  final ValueChanged<String>? onOptionTap;
  final ValueChanged<String>? onHistoryTap;
  final ValueChanged<SearchHistory>? onHistoryRemoved;
  final ValueChanged<String>? onTagTap;

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView>
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
              MetatagsSection(
                onOptionTap: widget.onOptionTap,
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(thickness: 1),
              FavoriteTagsSection(
                onTagTap: widget.onTagTap,
              ),
              const Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'search.trending'.tr().toUpperCase(),
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              BlocBuilder<SearchKeywordCubit, AsyncLoadState<List<Search>>>(
                builder: (context, state) {
                  return state.status != LoadStatus.success
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : Wrap(
                          spacing: 4,
                          runSpacing: -4,
                          children: state.data!
                              .take(15)
                              .map((e) => GestureDetector(
                                    onTap: () =>
                                        widget.onTagTap?.call(e.keyword),
                                    child: Chip(
                                      label: Text(
                                        e.keyword.replaceAll('_', ' '),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                },
              ),
              SearchHistorySection(
                onHistoryTap: (history) => widget.onHistoryTap?.call(history),
                onHistoryRemoved: (history) =>
                    widget.onHistoryRemoved?.call(history),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
