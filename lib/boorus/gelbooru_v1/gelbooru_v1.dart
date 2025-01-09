// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru_v1/create_gelbooru_v1_config_page.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_v1_client.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/html.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/widgets/info_container.dart';
import '../../core/configs/create/create.dart';

part 'providers.dart';

class GelbooruV1Builder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        CommentNotSupportedMixin,
        UnknownMetatagsMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultThumbnailUrlMixin,
        DefaultTagColorMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultGranularRatingFiltererMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  GelbooruV1Builder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
      }) =>
          CreateBooruConfigScope(
            id: id,
            config: BooruConfig.defaultConfig(
              booruType: id.booruType,
              url: id.url,
              customDownloadFileNameFormat:
                  kGelbooruCustomDownloadFileNameFormat,
            ),
            child: CreateGelbooruV1ConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreateGelbooruV1ConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => GelbooruV1SearchPage(
            initialQuery: initialQuery,
          );

  @override
  final DownloadFilenameGenerator downloadFilenameBuilder =
      DownloadFileNameBuilder(
    defaultFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kGelbooruCustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    tokenHandlers: {
      'source': (post, config) => config.downloadUrl,
    },
  );
}

class GelbooruV1SearchPage extends ConsumerWidget {
  const GelbooruV1SearchPage({
    super.key,
    required this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postRepo = ref.watch(postRepoProvider(ref.watchConfig));

    return SearchPageScaffold(
      noticeBuilder: (context) => InfoContainer(
        contentBuilder: (context) => const AppHtml(
          data: 'The app will use <b>Gelbooru</b> for tag completion.',
        ),
      ),
      initialQuery: initialQuery,
      fetcher: (page, controller) => postRepo.getPostsFromController(
        controller,
        page,
      ),
    );
  }
}
