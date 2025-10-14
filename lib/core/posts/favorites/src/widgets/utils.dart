// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/auth/types.dart';
import '../../../../configs/config/providers.dart';
import '../providers/favorites_notifier.dart';

extension FavX on WidgetRef {
  void toggleFavorite(int postId) {
    guardLogin(this, () async {
      final config = readConfigAuth;
      final notifier = read(favoritesProvider(config).notifier);
      final isFaved = read(favoriteProvider((config, postId)));
      if (isFaved) {
        await notifier.remove(postId);
        if (context.mounted) {
          showSuccessSnackBar(
            context,
            'Removed from favorites',
          );
        }
      } else {
        await notifier.add(postId);
        if (context.mounted) {
          showSuccessSnackBar(
            context,
            'Added to favorites',
          );
        }
      }
    });
  }
}
