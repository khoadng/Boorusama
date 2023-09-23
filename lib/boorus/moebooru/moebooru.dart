import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/moebooru/moebooru_scope.dart';

import 'create_moebooru_config_page.dart';

class MoebooruBuilder implements BooruBuilder {
  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateMoebooruConfigPage(
            url: url,
            booruType: booruType,
            backgroundColor: backgroundColor,
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => MoebooruScope(config: config);

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateMoebooruConfigPage(
            initialHashedPassword: config.apiKey,
            initialLogin: config.login,
            initialConfigName: config.name,
            initialRatingFilter: config.ratingFilter,
            booruType: config.booruType,
            url: config.url,
            backgroundColor: backgroundColor,
          );
}
