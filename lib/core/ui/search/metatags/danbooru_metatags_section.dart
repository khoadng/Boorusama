// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/core/application/current_booru_notifier.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/repositories/metatags.dart';
import 'package:boorusama/core/ui/search/user_data_metatags_section.dart';
import 'package:boorusama/core/utils.dart';

class DanbooruMetatagsSection extends ConsumerWidget {
  const DanbooruMetatagsSection({
    super.key,
    this.onOptionTap,
    required this.metatags,
  });

  final ValueChanged<String>? onOptionTap;
  final List<Metatag> metatags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruProvider);

    return UserDataMetatagsSection(
      onOptionTap: onOptionTap,
      metatags: metatags,
      onHelpRequest: () {
        launchExternalUrl(
          Uri.parse(booru.cheatsheet),
          mode: LaunchMode.platformDefault,
        );
      },
      userMetatagRepository: context.read<UserMetatagRepository>(),
    );
  }
}
