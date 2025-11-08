// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import 'types.dart';

final shimmie2LoginDetailsProvider =
    Provider.family<Shimmie2LoginDetails, BooruConfigAuth>(
      (ref, config) => Shimmie2LoginDetails(
        config: config,
        delegate: ApiAndCookieBasedLoginDetails(config: config),
      ),
    );
