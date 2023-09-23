import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/zerochan/zerochan.dart';
import 'package:flutter/widgets.dart';

typedef ConfigPageBuilder = Widget Function(
  BuildContext context,
  String url,
  BooruType booruType, {
  Color? backgroundColor,
});
typedef HomePageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
);

abstract class BooruBuilder {
  ConfigPageBuilder get configPageBuilder;
  HomePageBuilder get homePageBuilder;
}

//FIXME: shouldn't hardcode this, need to find a way to make this dynamic
final booruBuilders = {
  BooruType.zerochan: ZerochanBuilder(),
};
