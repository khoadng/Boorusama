// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/i18n.dart';

class FavoritePostButton extends StatelessWidget {
  const FavoritePostButton({
    super.key,
    required this.isFaved,
    required this.isAuthorized,
    required this.addFavorite,
    required this.removeFavorite,
  });

  final bool isFaved;
  final bool isAuthorized;
  final Future<void> Function() addFavorite;
  final Future<void> Function() removeFavorite;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 16,
      onPressed: () async {
        if (!isAuthorized) {
          showSimpleSnackBar(
            context: context,
            content: const Text(
              'post.detail.login_required_notice',
            ).tr(),
            duration: const Duration(seconds: 1),
          );

          return;
        }
        if (isFaved) {
          removeFavorite();
        } else {
          addFavorite();
        }
      },
      icon: isFaved
          ? const FaIcon(
              FontAwesomeIcons.solidHeart,
              color: Colors.red,
              size: 20,
            )
          : const FaIcon(
              FontAwesomeIcons.heart,
              size: 20,
            ),
    );
  }
}
