// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../post/types.dart';

final noteOverlayProvider = NotifierProvider.autoDispose
    .family<NoteOverlayNotifier, bool, (BooruConfigAuth, Post)>(
      NoteOverlayNotifier.new,
    );

class NoteOverlayNotifier
    extends AutoDisposeFamilyNotifier<bool, (BooruConfigAuth, Post)> {
  @override
  bool build((BooruConfigAuth, Post) params) {
    return false;
  }

  void setVisible(bool isVisible) {
    state = isVisible;
  }
}
