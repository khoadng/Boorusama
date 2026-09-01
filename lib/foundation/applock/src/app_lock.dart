// Dart imports:
import 'dart:async';
import 'dart:ui';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../pincode/pincode.dart';
import '../../loggers.dart';
import 'app_lock_session.dart';
import 'app_lock_type.dart';
import 'app_lock_capabilities.dart';
import 'app_privacy_platform.dart';
import 'biometrics.dart';

class AppLock extends ConsumerStatefulWidget {
  const AppLock({
    required this.child,
    required this.type,
    required this.timeout,
    super.key,
    this.hideAppPreviewWhenBackgrounded = true,
  });

  final AppLockType type;
  final Duration timeout;
  final bool hideAppPreviewWhenBackgrounded;
  final Widget child;

  @override
  ConsumerState<AppLock> createState() => _AppLockState();
}

class _AppLockState extends ConsumerState<AppLock> with WidgetsBindingObserver {
  late final bool _hasNativePrivacyCover;
  late final _session = AppLockSession(
    config: _config,
    now: DateTime.now,
  );
  var _authenticating = false;
  late var _buildProtectedContent = !_session.locked;

  AppLockSessionConfig get _config => AppLockSessionConfig(
    type: widget.type,
    timeout: widget.timeout,
    hideAppPreviewWhenBackgrounded: widget.hideAppPreviewWhenBackgrounded,
  );

  @override
  void initState() {
    super.initState();
    _hasNativePrivacyCover = ref
        .read(appLockCapabilitiesProvider)
        .nativePrivacyCover;
    WidgetsBinding.instance.addObserver(this);
    unawaited(_syncNativePrivacyCover());
  }

  @override
  void didUpdateWidget(covariant AppLock oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.hideAppPreviewWhenBackgrounded !=
        widget.hideAppPreviewWhenBackgrounded) {
      unawaited(_syncNativePrivacyCover());
    }

    setState(() {
      _session.updateConfig(_config);
      if (!_session.locked) {
        _buildProtectedContent = true;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_hasNativePrivacyCover) {
      unawaited(AppPrivacyPlatform.setPrivacyCoverEnabled(false));
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _session.didChangeAppLifecycleState(state));
  }

  Future<void> _syncNativePrivacyCover() async {
    if (!_hasNativePrivacyCover) return;

    await AppPrivacyPlatform.setPrivacyCoverEnabled(
      widget.hideAppPreviewWhenBackgrounded,
    );
  }

  Future<void> _authenticate(LocalAuthentication localAuth) async {
    if (_authenticating) return;

    final logger = ref.read(loggerProvider)
      ..info('Local Auth', 'Authenticating...');

    setState(() => _authenticating = true);

    try {
      final didAuthenticate = await startAuthenticate(
        localAuth,
        localizedReason:
            context.t.settings.privacy.app_lock.authenticate_reason,
      );

      if (didAuthenticate && mounted) {
        logger.info('Local Auth', 'Authenticated');
        setState(() {
          _session.unlock();
          _buildProtectedContent = true;
        });
      }
    } catch (e) {
      logger.error('Local Auth', 'Failed to authenticate: $e');
    } finally {
      if (mounted) {
        setState(() => _authenticating = false);
      }
    }
  }

  void _unlock() {
    setState(() {
      _session.unlock();
      _buildProtectedContent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_buildProtectedContent) widget.child else const SizedBox.expand(),
        if (_buildProtectedContent &&
            _session.privacyCoverVisible &&
            !_session.locked)
          const Positioned.fill(
            child: AppPrivacyCover(),
          ),
        if (_session.locked)
          Positioned.fill(
            child: _LockSurface(
              type: widget.type,
              authenticating: _authenticating,
              onBiometricUnlock: () =>
                  _authenticate(ref.read(biometricsProvider)),
              onPinUnlocked: _unlock,
            ),
          ),
      ],
    );
  }
}

class _LockSurface extends ConsumerWidget {
  const _LockSurface({
    required this.type,
    required this.authenticating,
    required this.onBiometricUnlock,
    required this.onPinUnlocked,
  });

  final AppLockType type;
  final bool authenticating;
  final VoidCallback onBiometricUnlock;
  final VoidCallback onPinUnlocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const padding = EdgeInsets.fromLTRB(20, 32, 20, 24);
            final minimumContentHeight = constraints.maxHeight > 56
                ? constraints.maxHeight - 56
                : 0.0;

            return SingleChildScrollView(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minimumContentHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: switch (type) {
                      AppLockType.pin => _PinLockSurface(
                        onUnlocked: onPinUnlocked,
                        onDeviceUnlock: onBiometricUnlock,
                      ),
                      AppLockType.biometrics => ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: _BiometricLockSurface(
                          authenticating: authenticating,
                          onUnlock: onBiometricUnlock,
                        ),
                      ),
                      AppLockType.none => const SizedBox.shrink(),
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PinLockSurface extends ConsumerStatefulWidget {
  const _PinLockSurface({
    required this.onUnlocked,
    required this.onDeviceUnlock,
  });

  final VoidCallback onUnlocked;
  final VoidCallback onDeviceUnlock;

  @override
  ConsumerState<_PinLockSurface> createState() => _PinLockSurfaceState();
}

class _PinLockSurfaceState extends ConsumerState<_PinLockSurface> {
  late final repository = ref.read(pinCredentialRepositoryProvider);
  late final Future<bool> hasPin = repository.hasPin();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: hasPin,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data != true) {
          return const _LockMessage(
            icon: Symbols.lock,
            title: null,
            message: null,
            messageType: _LockMessageType.locked,
          );
        }

        return PinUnlockPanel(
          title: context.t.settings.privacy.app_lock.unlock_app,
          onSubmit: repository.verifyPin,
          onUnlocked: widget.onUnlocked,
          onDeviceUnlock:
              (ref.watch(canUseBiometricLockProvider).valueOrNull ?? false)
              ? widget.onDeviceUnlock
              : null,
        );
      },
    );
  }
}

class _BiometricLockSurface extends ConsumerWidget {
  const _BiometricLockSurface({
    required this.authenticating,
    required this.onUnlock,
  });

  final bool authenticating;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(canUseBiometricLockProvider)
        .when(
          data: (canUse) {
            if (!canUse) {
              return const _LockMessage(
                icon: Symbols.lock,
                title: null,
                message: null,
                messageType: _LockMessageType.biometricUnavailable,
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.t.settings.privacy.app_lock.authenticate_to_use_app,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                IconButton(
                  onPressed: authenticating ? null : onUnlock,
                  icon: Icon(
                    Symbols.fingerprint,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (authenticating) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ],
            );
          },
          loading: () => const DelayedRenderWidget(
            delay: Duration(milliseconds: 500),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => const _LockMessage(
            icon: Symbols.lock,
            title: null,
            message: null,
            messageType: _LockMessageType.biometricFailed,
          ),
        );
  }
}

class AppPrivacyCover extends StatelessWidget {
  const AppPrivacyCover({super.key});

  static const _blurSigma = 96.0;
  static const _scrimOpacity = 0.42;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: ColoredBox(
          color: colorScheme.scrim.withValues(alpha: _scrimOpacity),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

enum _LockMessageType {
  custom,
  biometricUnavailable,
  biometricFailed,
  locked,
}

class _LockMessage extends StatelessWidget {
  const _LockMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.messageType = _LockMessageType.custom,
  });

  final IconData icon;
  final String? title;
  final String? message;
  final _LockMessageType messageType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appLock = context.t.settings.privacy.app_lock;
    final resolvedTitle =
        title ??
        switch (messageType) {
          _LockMessageType.biometricUnavailable =>
            appLock.biometric_unavailable,
          _LockMessageType.biometricFailed => appLock.biometric_failed,
          _LockMessageType.locked => appLock.locked_title,
          _LockMessageType.custom => '',
        };
    final resolvedMessage =
        message ??
        switch (messageType) {
          _LockMessageType.biometricUnavailable =>
            appLock.biometric_unavailable_description,
          _LockMessageType.biometricFailed =>
            appLock.biometric_failed_description,
          _LockMessageType.locked => appLock.locked_description,
          _LockMessageType.custom => '',
        };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 56,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          resolvedTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          resolvedMessage,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.outline),
        ),
      ],
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
