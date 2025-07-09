// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../config/types.dart';
import '../providers/providers.dart';

class BooruConfigDataProvider extends ConsumerWidget {
  const BooruConfigDataProvider({
    required this.builder,
    super.key,
  });

  final Widget Function(BooruConfigData data) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider)),
    );

    return builder(data);
  }
}
