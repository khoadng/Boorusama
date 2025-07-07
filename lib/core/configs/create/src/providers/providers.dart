// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../config/types.dart';
import '../types/edit_booru_config_id.dart';
import 'internal_providers.dart';

final editBooruConfigIdProvider = Provider.autoDispose<EditBooruConfigId>(
  (ref) => throw UnimplementedError(),
);

final initialBooruConfigProvider = Provider.autoDispose<BooruConfig>(
  (ref) => throw UnimplementedError(),
);

final editBooruConfigProvider = NotifierProvider.autoDispose
    .family<EditBooruConfigNotifier, BooruConfigData, EditBooruConfigId>(
      EditBooruConfigNotifier.new,
    );

extension UpdateDataX on WidgetRef {
  EditBooruConfigNotifier get editNotifier =>
      read(editBooruConfigProvider(read(editBooruConfigIdProvider)).notifier);
}
