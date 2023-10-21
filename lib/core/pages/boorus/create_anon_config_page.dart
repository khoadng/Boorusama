// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/router.dart';

class CreateAnonConfigPage extends ConsumerStatefulWidget {
  const CreateAnonConfigPage({
    super.key,
    required this.config,
    this.backgroundColor,
  });

  final BooruConfig config;
  final Color? backgroundColor;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateAnonConfigPageState();
}

class _CreateAnonConfigPageState extends ConsumerState<CreateAnonConfigPage> {
  late String configName = widget.config.name;
  late String? customDownloadFileNameFormat =
      widget.config.customDownloadFileNameFormat;

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      backgroundColor: widget.backgroundColor,
      booruType: widget.config.booruType,
      url: widget.config.url,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CreateBooruConfigNameField(
                text: configName,
                onChanged: (value) => setState(() => configName = value),
              ),
              // CreateBooruCustomDownloadFileNameField(
              //   format: customDownloadFileNameFormat,
              //   onChanged: (value) =>
              //       setState(() => customDownloadFileNameFormat = value),
              // ),
              CreateBooruSubmitButton(
                onSubmit: allowSubmit() ? submit : null,
              ),
            ],
          ),
        ),
      ],
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
            booru: widget.config.booruType,
            booruHint: widget.config.booruType,
            configName: configName,
            hideDeleted: false,
            ratingFilter: BooruConfigRatingFilter.none,
            url: widget.config.url,
            customDownloadFileNameFormat: customDownloadFileNameFormat,
          ),
        );
    context.pop();
  }
}
