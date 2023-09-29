// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_v1_client.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/pages/boorus/create_anon_config_page.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/functional.dart';

part 'providers.dart';

class GelbooruV1Builder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  const GelbooruV1Builder({
    required this.postRepo,
  });

  final PostRepository postRepo;

  @override
  AutocompleteFetcher get autocompleteFetcher => (tags) => Future.value([]);

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateAnonConfigPage(
            url: url,
            booruType: booruType,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => TaskEither.Do(($) async {
        final posts = await $(postRepo.getPosts(tags, page));

        return posts;
      });
}
