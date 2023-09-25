// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/create_anon_config_page.dart';
import 'package:boorusama/router.dart';

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
