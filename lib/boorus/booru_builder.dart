// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
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

abstract class BooruBuilder {
  HomePageBuilder get homePageBuilder;
  CreateConfigPageBuilder get createConfigPageBuilder;
  UpdateConfigPageBuilder get updateConfigPageBuilder;
}

//FIXME: shouldn't hardcode this, need to find a way to make this dynamic
final booruBuilders = {
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
};
