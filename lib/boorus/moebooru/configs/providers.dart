// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/configs/config/types.dart';

final moebooruLoginDetailsProvider =
    Provider.family<BooruLoginDetails, BooruConfigAuth>(
      (ref, config) => ref.watch(defaultLoginDetailsProvider(config)),
    );
