// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/explores/explores.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/datetimes/datetimes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';

class ExploreMostViewedPage extends ConsumerWidget {
  const ExploreMostViewedPage({
    super.key,
  });

  static Widget routeOf(BuildContext context) => CustomContextMenuOverlay(
        child: ProviderScope(
          overrides: [
            dateProvider.overrideWith((ref) => DateTime.now()),
          ],
          child: const ExploreMostViewedPage(),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dateProvider);
    final config = ref.watchConfig;

    return PostScope(
      fetcher: (page) => page > 1
          ? TaskEither.fromEither(Either.of(<DanbooruPost>[].toResult()))
          : ref
              .read(danbooruExploreRepoProvider(config))
              .getMostViewedPosts(date),
      builder: (context, controller, errors) => _MostViewedContent(
        controller: controller,
        errors: errors,
      ),
    );
  }
}

class _MostViewedContent extends ConsumerWidget {
  const _MostViewedContent({
    required this.controller,
    this.errors,
  });

  final PostGridController<DanbooruPost> controller;
  final BooruError? errors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dateProvider);

    ref.listen(
      dateProvider,
      (previous, next) async {
        if (previous != next) {
          // Delay 100ms, this is a hack
          await const Duration(milliseconds: 100).future;
          controller.refresh();
        }
      },
    );

    return Container(
      color: context.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: DanbooruInfinitePostList(
                errors: errors,
                controller: controller,
                safeArea: false,
                sliverHeaders: [
                  ExploreSliverAppBar(
                    title: 'explore.most_viewed'.tr(),
                  ),
                ],
              ),
            ),
            Container(
              color: context.theme.bottomNavigationBarTheme.backgroundColor,
              child: DateTimeSelector(
                onDateChanged: (date) =>
                    ref.read(dateProvider.notifier).state = date,
                date: date,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
