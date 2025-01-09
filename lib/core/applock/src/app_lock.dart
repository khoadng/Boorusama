// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../foundation/loggers.dart';
import '../../foundation/networking.dart';
import 'biometrics.dart';

class AppLock extends ConsumerStatefulWidget {
  const AppLock({
    required this.child,
    super.key,
    this.enable = true,
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
        unawaited(_authenticate(ref.read(biometricsProvider)));
      });
    }
  }

  Future<void> _authenticate(LocalAuthentication localAuth) async {
    final logger = ref.read(loggerProvider)
      ..logI('Local Auth', 'Authenticating...');

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
        logger
          ..logE('Local Auth', 'Failed to authenticate: $e')
          ..logI('Local Auth', 'Auto unlocked');
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

    return Material(
      child: ref.watch(canUseBiometricLockProvider).when(
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
                      ),
                    ],
                  ),
                );
              }

              return widget.child;
            },
            loading: () => const DelayedRenderWidget(
              delay: Duration(milliseconds: 500),
              child: Material(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, stack) => widget.child,
          ),
    );
  }
}

class DelayedRenderWidget extends StatefulWidget {
  const DelayedRenderWidget({
    required this.delay,
    required this.child,
    super.key,
    this.placeholder,
  });

  final Duration delay;
  final Widget? placeholder;
  final Widget child;

  @override
  State<DelayedRenderWidget> createState() => _DelayedRenderWidgetState();
}

class _DelayedRenderWidgetState extends State<DelayedRenderWidget> {
  late Timer? _timer;
  var _shouldRender = false;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      widget.delay,
      () {
        setState(() {
          _shouldRender = true;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _shouldRender
        ? widget.child
        : widget.placeholder ?? const SizedBox.shrink();
  }
}
