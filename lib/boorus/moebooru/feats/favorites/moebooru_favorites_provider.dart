// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/favorites/moebooru_favorites_notifier.dart';

final moebooruFavoritesProvider =
    NotifierProvider.family<MoebooruFavoritesNotifier, Set<String>?, int>(
        MoebooruFavoritesNotifier.new);
