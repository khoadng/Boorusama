// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../boorus/engine/providers.dart';
import '../configs/config/types.dart';
import 'types.dart';

final defaultAppErrorTranslatorProvider = Provider<AppErrorTranslator>(
  (ref) => DefaultAppErrorTranslator(),
);

final appErrorTranslatorProvider =
    Provider.family<AppErrorTranslator, BooruConfigAuth>(
      (ref, config) {
        final repository = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        if (repository == null) {
          return ref.watch(defaultAppErrorTranslatorProvider);
        }

        return repository.appErrorTranslator(config);
      },
      name: 'appErrorTranslatorProvider',
    );
