// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'src/developer_options_repository.dart';
import 'types.dart';

final developerOptionsRepositoryProvider = Provider<DeveloperOptionsRepository>(
  (ref) => throw UnimplementedError(),
  name: 'developerOptionsRepositoryProvider',
);

final developerOptionsNotifierProvider =
    NotifierProvider<DeveloperOptionsNotifier, DeveloperOptions>(
      () => throw UnimplementedError(),
      name: 'developerOptionsNotifierProvider',
    );

final automaticMediaLoadingEnabledProvider = Provider<bool>(
  (ref) => ref.watch(
    developerOptionsNotifierProvider.select(
      (options) => options.automaticMediaLoadingEnabled,
    ),
  ),
  name: 'automaticMediaLoadingEnabledProvider',
);

class DeveloperOptionsNotifier extends Notifier<DeveloperOptions> {
  DeveloperOptionsNotifier(this.initialOptions);

  final DeveloperOptions initialOptions;

  @override
  DeveloperOptions build() => initialOptions;

  Future<void> setAutomaticMediaLoadingEnabled(bool enabled) async {
    final options = state.copyWith(
      automaticMediaLoadingEnabled: enabled,
    );

    await ref.read(developerOptionsRepositoryProvider).save(options);
    state = options;
  }
}
