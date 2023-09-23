// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/autocomplete/e621_autocomplete_provider.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/feats/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/moebooru/feats/autocomplete/moebooru_autocomplete_provider.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/zerochan/zerochan.dart';
import 'danbooru/feats/posts/posts.dart';

typedef CreateConfigPageBuilder = Widget Function(
  BuildContext context,
  String url,
  BooruType booruType, {
  Color? backgroundColor,
});

typedef UpdateConfigPageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config, {
  Color? backgroundColor,
});

typedef HomePageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
);

typedef PostFetcher = PostsOrError Function(
  int page,
  String tags,
);

typedef AutocompleteFetcher = Future<List<AutocompleteData>> Function(
  String query,
);

abstract class BooruBuilder {
  // UI Builders
  HomePageBuilder get homePageBuilder;
  CreateConfigPageBuilder get createConfigPageBuilder;
  UpdateConfigPageBuilder get updateConfigPageBuilder;

  // Data Builders
  PostFetcher get postFetcher;
  AutocompleteFetcher get autocompleteFetcher;
}

final booruBuildersProvider = Provider<Map<BooruType, BooruBuilder>>((ref) => {
      BooruType.zerochan: ZerochanBuilder(
        client: ref.watch(zerochanClientProvider),
        settingsRepository: ref.watch(settingsRepoProvider),
      ),
      BooruType.konachan: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
        autocompleteRepo: ref.watch(moebooruAutocompleteRepoProvider),
      ),
      BooruType.yandere: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
        autocompleteRepo: ref.watch(moebooruAutocompleteRepoProvider),
      ),
      BooruType.sakugabooru: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
        autocompleteRepo: ref.watch(moebooruAutocompleteRepoProvider),
      ),
      BooruType.lolibooru: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
        autocompleteRepo: ref.watch(moebooruAutocompleteRepoProvider),
      ),
      BooruType.gelbooru: GelbooruBuilder(
        postRepo: ref.watch(gelbooruPostRepoProvider),
        autocompleteRepo: ref.watch(gelbooruAutocompleteRepoProvider),
      ),
      BooruType.rule34xxx: GelbooruBuilder(
        postRepo: ref.watch(gelbooruPostRepoProvider),
        autocompleteRepo: ref.watch(gelbooruAutocompleteRepoProvider),
      ),
      BooruType.e621: E621Builder(
        postRepo: ref.watch(e621PostRepoProvider),
        autocompleteRepo: ref.watch(e621AutocompleteRepoProvider),
      ),
      BooruType.e926: E621Builder(
        postRepo: ref.watch(e621PostRepoProvider),
        autocompleteRepo: ref.watch(e621AutocompleteRepoProvider),
      ),
      BooruType.aibooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
        autocompleteRepo: ref.watch(danbooruAutocompleteRepoProvider),
      ),
      BooruType.danbooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
        autocompleteRepo: ref.watch(danbooruAutocompleteRepoProvider),
      ),
      BooruType.safebooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
        autocompleteRepo: ref.watch(danbooruAutocompleteRepoProvider),
      ),
      BooruType.testbooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
        autocompleteRepo: ref.watch(danbooruAutocompleteRepoProvider),
      ),
    });
