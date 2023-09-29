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
    required this.url,
    required this.booruType,
    this.backgroundColor,
  });

  final String url;
  final BooruType booruType;
  final Color? backgroundColor;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateAnonConfigPageState();
}

class _CreateAnonConfigPageState extends ConsumerState<CreateAnonConfigPage> {
  var configName = '';

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      backgroundColor: widget.backgroundColor,
      booruType: widget.booruType,
      url: widget.url,
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
