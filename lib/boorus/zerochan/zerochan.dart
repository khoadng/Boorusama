import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/create_anon_config_page.dart';
import 'package:boorusama/boorus/zerochan/zerochan_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ZerochanBuilder implements BooruBuilder {
  @override
  ConfigPageBuilder get configPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          ZerochanCreateConfigPage(
            url: url,
            booruType: booruType,
            backgroundColor: backgroundColor,
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => ZerochanScope(config: config);
}

class ZerochanCreateConfigPage extends ConsumerStatefulWidget {
  const ZerochanCreateConfigPage({
    super.key,
    required this.url,
    required this.booruType,
    this.backgroundColor,
  });

  final String url;
  final BooruType booruType;
  final Color? backgroundColor;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ZerochanCreateConfigPageState();
}

class _ZerochanCreateConfigPageState
    extends ConsumerState<ZerochanCreateConfigPage> {
  var configName = '';

  @override
  Widget build(BuildContext context) {
    return CreateAnonConfigPage(
      backgroundColor: widget.backgroundColor,
      onConfigNameChanged: (value) => setState(() => configName = value),
      onSubmit: allowSubmit() ? submit : null,
      booruType: widget.booruType,
      url: widget.url,
    );
  }

  bool allowSubmit() {
    return configName.isNotEmpty;
  }

  void submit() {
    ref.read(booruConfigProvider.notifier).addFromAddBooruConfig(
          newConfig: AddNewBooruConfig(
            login: '',
            apiKey: '',
            booru: widget.booruType,
            booruHint: widget.booruType,
            configName: configName,
            hideDeleted: false,
            ratingFilter: BooruConfigRatingFilter.none,
            url: widget.url,
          ),
        );
    context.pop();
  }
}
