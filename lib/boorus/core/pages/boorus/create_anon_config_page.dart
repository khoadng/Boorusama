// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'widgets/create_booru_config_name_field.dart';

class CreateAnonConfigPage extends StatelessWidget {
  const CreateAnonConfigPage({
    super.key,
    required this.onConfigNameChanged,
    required this.onSubmit,
    required this.booruType,
    required this.url,
    this.initialConfigName,
    this.backgroundColor,
    this.isUnkown = false,
  });

  final String? initialConfigName;

  final void Function(String value) onConfigNameChanged;
  final void Function()? onSubmit;

  final Color? backgroundColor;

  final BooruType booruType;
  final String url;
  final bool isUnkown;

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      backgroundColor: backgroundColor,
      booruType: booruType,
      url: url,
      isUnknown: isUnkown,
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
                text: initialConfigName,
                onChanged: onConfigNameChanged,
              ),
              CreateBooruSubmitButton(onSubmit: onSubmit),
            ],
          ),
        ),
      ],
    );
  }
}
