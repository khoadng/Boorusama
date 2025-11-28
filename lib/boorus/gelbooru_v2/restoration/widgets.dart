// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/position/providers.dart';
import '../../../core/posts/position/types.dart';
import '../../../core/posts/position/widgets.dart';
import '../../../core/search/search/routes.dart';
import '../../../core/search/selected_tags/types.dart';
import '../../../core/settings/providers.dart';
import 'utils.dart';

class GelbooruV2SessionRestorePage extends ConsumerWidget {
  const GelbooruV2SessionRestorePage({
    super.key,
    required this.snapshot,
  });

  final PaginationSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watchConfigSearch;

    return PageFindingDialog(
      config: PageFinderConfig(
        repository: ref.read(
          defaultPostPageFinderRepoProvider(search),
        ),
        userChunkSize: ref.read(imageListingSettingsProvider).postsPerPage,
      ),
      snapshot: snapshot,
      onSuccess: (location) {
        goToSearchPage(
          ref,
          tag: snapshot.tags,
          queryType: QueryType.simple,
          position: location.index,
          page: location.page,
        );
      },
      paginationLimitView: (context) => PaginationLimitView(
        onContinueBrowsing: () {
          goToSearchPage(
            ref,
            tag: buildIdContinuationQuery(snapshot),
          );
        },
      ),
    );
  }
}
