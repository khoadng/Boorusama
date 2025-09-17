// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/configs/config/src/providers/providers.dart';

final gelbooruV2LoginDetailsProvider =
    Provider.family<BooruLoginDetails, BooruConfigAuth>(
      (ref, config) => ref.watch(defaultLoginDetailsProvider(config)),
    );
