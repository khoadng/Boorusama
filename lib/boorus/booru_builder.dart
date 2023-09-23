// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/zerochan/zerochan.dart';
import 'package:boorusama/boorus/zerochan/zerochan_provider.dart';
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

abstract class BooruBuilder {
  // UI Builders
  HomePageBuilder get homePageBuilder;
  CreateConfigPageBuilder get createConfigPageBuilder;
  UpdateConfigPageBuilder get updateConfigPageBuilder;

  // Data Builders
  PostFetcher get postFetcher;
}

final booruBuildersProvider = Provider<Map<BooruType, BooruBuilder>>((ref) => {
      BooruType.zerochan: ZerochanBuilder(
        client: ref.watch(zerochanClientProvider),
        settingsRepository: ref.watch(settingsRepoProvider),
      ),
      BooruType.konachan: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
      ),
      BooruType.yandere: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
      ),
      BooruType.sakugabooru: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
      ),
      BooruType.lolibooru: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
      ),
      BooruType.gelbooru: GelbooruBuilder(
        postRepo: ref.watch(gelbooruPostRepoProvider),
      ),
      BooruType.rule34xxx: GelbooruBuilder(
        postRepo: ref.watch(gelbooruPostRepoProvider),
      ),
      BooruType.e621: E621Builder(
        postRepo: ref.watch(e621PostRepoProvider),
      ),
      BooruType.e926: E621Builder(
        postRepo: ref.watch(e621PostRepoProvider),
      ),
      BooruType.aibooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
      ),
      BooruType.danbooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
      ),
      BooruType.safebooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
      ),
      BooruType.testbooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
      ),
    });
