// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/infra/repositories/metatags.dart';
import 'package:boorusama/core/ui/search/user_data_metatags_section.dart';
import 'package:boorusama/core/utils.dart';

class DanbooruMetatagsSection extends StatelessWidget {
  const DanbooruMetatagsSection({
    super.key,
    this.onOptionTap,
  });

  final ValueChanged<String>? onOptionTap;

  @override
  Widget build(BuildContext context) {
    final metatags = context.select((SearchBloc bloc) => bloc.state.metatags);
    final booru = context.select((CurrentBooruBloc bloc) => bloc.state.booru);

    return UserDataMetatagsSection(
      onOptionTap: onOptionTap,
      metatags: metatags,
      onHelpRequest: () {
        launchExternalUrl(
          Uri.parse(booru!.cheatsheet),
          mode: LaunchMode.platformDefault,
        );
      },
      userMetatagRepository: context.read<UserMetatagRepository>(),
    );
  }
}
