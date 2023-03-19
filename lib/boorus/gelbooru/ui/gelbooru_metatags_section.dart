// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infra/local/repositories/metatags/user_metatag_repository.dart';
import 'package:boorusama/core/domain/tags/tags.dart';
import 'package:boorusama/core/ui/search/user_data_metatags_section.dart';
import 'package:boorusama/core/utils.dart';

class GelbooruMetatagsSection extends StatelessWidget {
  const GelbooruMetatagsSection({
    super.key,
    this.onOptionTap,
    required this.metatags,
    required this.userMetatagRepository,
    required this.cheatsheetUrl,
  });

  final ValueChanged<String>? onOptionTap;
  final List<Metatag> metatags;
  final UserMetatagRepository userMetatagRepository;
  final String cheatsheetUrl;

  @override
  Widget build(BuildContext context) {
    return UserDataMetatagsSection(
      onOptionTap: onOptionTap,
      metatags: metatags,
      onHelpRequest: () {
        launchExternalUrl(
          Uri.parse(cheatsheetUrl),
          mode: LaunchMode.platformDefault,
        );
      },
      userMetatagRepository: userMetatagRepository,
    );
  }
}
