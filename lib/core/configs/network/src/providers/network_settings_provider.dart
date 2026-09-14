// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../config/types.dart';

final networkSettingsProvider =
    Provider.family<NetworkSettings, BooruConfigAuth>(
      (ref, config) => config.networkSettings ?? const NetworkSettings(),
    );
