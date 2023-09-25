// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';

class PoolSearchButton extends ConsumerWidget {
  const PoolSearchButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      splashRadius: 24,
      onPressed: () {
        goToPoolSearchPage(context, ref);
      },
      icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
    );
  }
}
