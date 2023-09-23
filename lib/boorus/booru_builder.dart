// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/zerochan/zerochan.dart';

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

typedef PostFetcher = Future<List<Post>> Function(int page, List<String> tags,
    {int limit});

abstract class BooruBuilder {
  // UI Builders
  HomePageBuilder get homePageBuilder;
  CreateConfigPageBuilder get createConfigPageBuilder;
  UpdateConfigPageBuilder get updateConfigPageBuilder;

  // Data Builders
  // PostFetcher get postFetcher;
}

final booruBuildersProvider = Provider<Map<BooruType, BooruBuilder>>((ref) => {
      BooruType.zerochan: ZerochanBuilder(),
      BooruType.konachan: MoebooruBuilder(),
      BooruType.yandere: MoebooruBuilder(),
      BooruType.sakugabooru: MoebooruBuilder(),
      BooruType.lolibooru: MoebooruBuilder(),
      BooruType.gelbooru: GelbooruBuilder(),
      BooruType.rule34xxx: GelbooruBuilder(),
      BooruType.e621: E621Builder(),
      BooruType.e926: E621Builder(),
      BooruType.aibooru: DanbooruBuilder(),
      BooruType.danbooru: DanbooruBuilder(),
      BooruType.safebooru: DanbooruBuilder(),
      BooruType.testbooru: DanbooruBuilder(),
    });
