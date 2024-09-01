// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'biometrics.dart';

class AppLock extends ConsumerStatefulWidget {
  const AppLock({
    super.key,
    this.enable = true,
    required this.child,
  });

  final bool enable;
  final Widget child;

  @override
  ConsumerState<AppLock> createState() => _AppLockState();
}

class _AppLockState extends ConsumerState<AppLock> {
  late var unlocked = !widget.enable;

  @override
  void initState() {
    super.initState();
    if (widget.enable) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _authenticate(ref.read(biometricsProvider));
      });
    }
  }

  Future<void> _authenticate(LocalAuthentication localAuth) async {
    final logger = ref.read(loggerProvider);

    logger.logI('Local Auth', 'Authenticating...');

    try {
      final didAuthenticate = await startAuthenticate(localAuth);

      if (didAuthenticate) {
        setState(() {
          logger.logI('Local Auth', 'Authenticated');
          unlocked = true;
        });
      }
    } catch (e) {
      setState(() {
        logger.logE('Local Auth', 'Failed to authenticate: $e');
        logger.logI('Local Auth', 'Auto unlocked');
        unlocked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localAuth = ref.watch(biometricsProvider);

    ref.listen(
      networkStateProvider,
      (previous, next) {
        // Just here to create the stream
      },
    );

    return Scaffold(
      body: ref.watch(canUseBiometricLockProvider).when(
            data: (canUse) {
              if (canUse && !unlocked) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Please authenticate to use the app',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    IconButton(
                      onPressed: () => _authenticate(localAuth),
                      icon: Icon(
                        Symbols.fingerprint,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  ],
                ));
              }

              return widget.child;
            },
            loading: () => const Material(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => widget.child,
          ),
    );
  }
}
