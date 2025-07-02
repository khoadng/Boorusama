// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import 'providers.dart';

class AnimePicturesCurrentUserIdScope extends ConsumerWidget {
  const AnimePicturesCurrentUserIdScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(animePicturesCurrentUserIdProvider(ref.watchConfigAuth))
        .when(
          data: (value) => value != null
              ? ProviderScope(
                  overrides: [
                    uidProvider.overrideWithValue(value),
                  ],
                  child: child,
                )
              : _buildInvalidPage(),
          loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => _buildInvalidPage(),
        );
  }

  Widget _buildInvalidPage() {
    return const Scaffold(
      body: Center(
        child: Text('You need to provide login details to use this feature.'),
      ),
    );
  }
}
