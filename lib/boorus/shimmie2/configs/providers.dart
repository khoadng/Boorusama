// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';

final shimmie2LoginDetailsProvider =
    Provider.family<BooruLoginDetails, BooruConfigAuth>(
      (ref, config) => ApiAndCookieBasedLoginDetails(config: config),
    );
