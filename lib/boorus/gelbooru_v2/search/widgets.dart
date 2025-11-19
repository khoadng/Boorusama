// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/search/search/routes.dart';
import '../../../core/search/search/widgets.dart';
import '../../../core/tags/metatag/widgets.dart';
import '../posts/providers.dart';
import '../tags/providers.dart';

class GelbooruV2SearchPage extends ConsumerWidget {
  const GelbooruV2SearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(gelbooruV2PostRepoProvider(config));
    final metatagPattern = ref.watch(
      gelbooruV2MetatagRegexProvider(config.auth),
    );

    return SearchPageScaffold(
      params: params,
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller.tagSet, page),
      textMatchers: [
        RegexMatcher(
          pattern: metatagPattern,
          spanBuilder: (match) => WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MetatagContainer(
              tag: match.text,
            ),
          ),
        ),
      ],
    );
  }
}
