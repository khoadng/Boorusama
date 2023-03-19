// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/infra/local/repositories/metatags/user_metatag_repository.dart';
import 'package:boorusama/core/ui/search/user_data_metatags_section.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/main.dart';

class DanbooruMetatagsSection extends StatelessWidget {
  const DanbooruMetatagsSection({
    super.key,
    this.onOptionTap,
  });

  final ValueChanged<String>? onOptionTap;

  @override
  Widget build(BuildContext context) {
    final metatags = context.select((SearchBloc bloc) => bloc.state.metatags);

    return UserDataMetatagsSection(
      onOptionTap: onOptionTap,
      metatags: metatags,
      onHelpRequest: () {
        launchExternalUrl(
          Uri.parse(cheatsheetUrl),
          mode: LaunchMode.platformDefault,
        );
      },
      userMetatagRepository: context.read<UserMetatagRepository>(),
    );
  }
}
