// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/infinite_post_list.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';

class TagDetailPage extends StatelessWidget
    with DanbooruArtistCharacterPostCubitMixin {
  const TagDetailPage({
    super.key,
    required this.tagName,
    required this.otherNamesBuilder,
    required this.backgroundImageUrl,
    this.includeHeaders = true,
  });

  final String tagName;
  final String backgroundImageUrl;
  final Widget Function(BuildContext context) otherNamesBuilder;
  final bool includeHeaders;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DanbooruArtistCharacterPostCubit,
        DanbooruArtistCharacterPostState>(
      builder: (context, state) {
        return InfinitePostList(
          state: state,
          onLoadMore: () => fetch(context),
          onRefresh: (controller) => refresh(context),
          sliverHeaderBuilder: (context) => [
            if (includeHeaders)
              SliverAppBar(
                floating: true,
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                actions: [
                  IconButton(
                    onPressed: () {
                      goToBulkDownloadPage(
                        context,
                        [tagName],
                      );
                    },
                    icon: const Icon(Icons.download),
                  ),
                ],
              ),
            if (includeHeaders)
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TagTitleName(tagName: tagName),
                    otherNamesBuilder(context),
                  ],
                ),
              ),
            if (includeHeaders)
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 10),
              sliver: SliverToBoxAdapter(
                child: CategoryToggleSwitch(
                  onToggle: (category) => changeCategory(context, category),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ignore: prefer-single-widget-per-file
class TagTitleName extends StatelessWidget {
  const TagTitleName({
    super.key,
    required this.tagName,
  });

  final String tagName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        tagName.removeUnderscoreWithSpace(),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

// ignore: prefer-single-widget-per-file
class CategoryToggleSwitch extends StatefulWidget {
  const CategoryToggleSwitch({
    super.key,
    required this.onToggle,
  });

  final void Function(TagFilterCategory category) onToggle;

  @override
  State<CategoryToggleSwitch> createState() => _CategoryToggleSwitchState();
}

class _CategoryToggleSwitchState extends State<CategoryToggleSwitch> {
  final ValueNotifier<int> selected = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<int>(
        valueListenable: selected,
        builder: (context, value, _) => ToggleSwitch(
          customTextStyles: const [
            TextStyle(fontWeight: FontWeight.w700),
            TextStyle(fontWeight: FontWeight.w700),
          ],
          changeOnTap: false,
          initialLabelIndex: value,
          minWidth: 100,
          minHeight: 30,
          cornerRadius: 5,
          labels: [
            'tag.explore.new'.tr(),
            'tag.explore.popular'.tr(),
          ],
          activeBgColor: [Theme.of(context).colorScheme.primary],
          inactiveBgColor: Theme.of(context).colorScheme.background,
          borderWidth: 1,
          borderColor: [Theme.of(context).hintColor],
          onToggle: (index) {
            index == 0
                ? widget.onToggle(TagFilterCategory.newest)
                : widget.onToggle(TagFilterCategory.popular);

            selected.value = index ?? 0;
          },
        ),
      ),
    );
  }
}
