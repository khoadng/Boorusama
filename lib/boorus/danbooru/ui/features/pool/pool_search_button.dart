// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';

class PoolSearchButton extends StatelessWidget {
  const PoolSearchButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        goToPoolSearchPage(context);
      },
      icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
    );
  }
}
