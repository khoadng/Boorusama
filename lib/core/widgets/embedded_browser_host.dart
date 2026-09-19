// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/browser/types.dart';
import '../../foundation/url_launcher.dart';

typedef EmbeddedBrowserReady = Future<void> Function(
  EmbeddedBrowserSession session,
);

class EmbeddedBrowserHost extends ConsumerStatefulWidget {
  const EmbeddedBrowserHost({
    required this.factory,
    required this.initialUri,
    this.userAgent,
    this.onReady,
    this.onEvent,
    this.onSessionClosing,
    this.onFailure,
    super.key,
  });

  final EmbeddedBrowserFactory factory;
  final Uri initialUri;
  final String? userAgent;
  final EmbeddedBrowserReady? onReady;
  final void Function(BrowserEvent event)? onEvent;
  final VoidCallback? onSessionClosing;
  final void Function(EmbeddedBrowserException error)? onFailure;

  @override
  ConsumerState<EmbeddedBrowserHost> createState() =>
      _EmbeddedBrowserHostState();
}

enum _HostState { checking, initializing, ready, failed }

class _EmbeddedBrowserHostState extends ConsumerState<EmbeddedBrowserHost> {
  _HostState _state = _HostState.checking;
  EmbeddedBrowserSession? _session;
  StreamSubscription<BrowserEvent>? _eventsSubscription;
  EmbeddedBrowserException? _failure;
  var _generation = 0;

  static final _runtimeDownloadUrl = Uri.parse(
    'https://developer.microsoft.com/en-us/microsoft-edge/webview2/',
  );

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  bool _isCurrent(int generation) => mounted && generation == _generation;

  Future<void> _start() async {
    final generation = ++_generation;
    final oldSession = _session;
    _session = null;
    await _eventsSubscription?.cancel();
    _eventsSubscription = null;
    widget.onSessionClosing?.call();
    unawaited(oldSession?.dispose() ?? Future<void>.value());
    if (mounted) setState(() => _state = _HostState.checking);

    if (!_validInitialUri(widget.initialUri)) {
      _fail(
        generation,
        const EmbeddedBrowserException(
          reason: EmbeddedBrowserFailureReason.initializationFailed,
          code: 'invalid_initial_url',
        ),
      );
      return;
    }

    try {
      final availability = await widget.factory.checkAvailability();
      if (!_isCurrent(generation)) return;
      if (!availability.isAvailable) {
        final reason = switch (availability.kind) {
          BrowserAvailabilityKind.unsupportedPlatform =>
            EmbeddedBrowserFailureReason.unsupportedPlatform,
          BrowserAvailabilityKind.runtimeMissing =>
            EmbeddedBrowserFailureReason.runtimeMissing,
          BrowserAvailabilityKind.initializationFailed =>
            EmbeddedBrowserFailureReason.initializationFailed,
          BrowserAvailabilityKind.available =>
            EmbeddedBrowserFailureReason.initializationFailed,
        };
        _fail(
          generation,
          EmbeddedBrowserException(
            reason: reason,
            code: availability.failureCode,
          ),
        );
        return;
      }

      if (mounted) setState(() => _state = _HostState.initializing);
      final creation = widget.factory.createSession();
      unawaited(
        creation.then<void>(
          (lateSession) {
            if (!_isCurrent(generation)) unawaited(lateSession.dispose());
          },
          onError: (_, _) {},
        ),
      );
      final session = await creation.timeout(const Duration(seconds: 30));
      if (!_isCurrent(generation)) {
        await session.dispose();
        return;
      }

      // Take ownership before any post-creation setup can throw so the
      // failure path releases the native controller as well.
      _session = session;
      final userAgent = widget.userAgent?.trim();
      if (userAgent != null && userAgent.isNotEmpty) {
        await session.setUserAgent(userAgent);
      }
      if (!_isCurrent(generation)) {
        await session.dispose();
        return;
      }

      _eventsSubscription = session.events.listen(widget.onEvent);
      if (mounted) setState(() => _state = _HostState.ready);
      await Future<void>.delayed(Duration.zero);
      if (!_isCurrent(generation)) return;
      await widget.onReady?.call(session);
      if (!_isCurrent(generation)) return;
      await session.load(widget.initialUri);
    } on TimeoutException {
      _fail(
        generation,
        const EmbeddedBrowserException(
          reason: EmbeddedBrowserFailureReason.operationTimeout,
          code: 'initialization_timeout',
        ),
      );
    } on EmbeddedBrowserException catch (error) {
      _fail(generation, error);
    } catch (error) {
      _fail(
        generation,
        EmbeddedBrowserException(
          reason: EmbeddedBrowserFailureReason.initializationFailed,
          code: error.runtimeType.toString(),
        ),
      );
    }
  }

  void _fail(int generation, EmbeddedBrowserException error) {
    if (!_isCurrent(generation)) return;
    _generation++;
    final session = _session;
    _session = null;
    unawaited(_eventsSubscription?.cancel() ?? Future<void>.value());
    _eventsSubscription = null;
    widget.onSessionClosing?.call();
    unawaited(session?.dispose() ?? Future<void>.value());
    widget.onFailure?.call(error);
    if (mounted) {
      setState(() {
        _failure = error;
        _state = _HostState.failed;
      });
    }
  }

  bool _validInitialUri(Uri uri) =>
      (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (_state == _HostState.ready && session != null) {
      return session.buildView(key: const ValueKey('embedded-browser-view'));
    }
    if (_state == _HostState.failed) return _buildFailure(context);
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildFailure(BuildContext context) {
    final failure = _failure;
    final missingRuntime =
        failure?.reason == EmbeddedBrowserFailureReason.runtimeMissing;
    final unsupported =
        failure?.reason == EmbeddedBrowserFailureReason.unsupportedPlatform;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              unsupported
                  ? 'Embedded browser is unavailable on this platform.'
                  : missingRuntime
                  ? 'Microsoft Edge WebView2 Runtime is required.'
                  : 'The embedded browser could not be initialized.',
              textAlign: TextAlign.center,
            ),
            if (failure?.code case final code?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Code: $code'),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                if (missingRuntime)
                  OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(externalUrlLauncherProvider)
                          .launch(
                            _runtimeDownloadUrl,
                          );
                    },
                    child: const Text('Open download page'),
                  ),
                FilledButton(
                  onPressed: unsupported ? null : () => unawaited(_start()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _generation++;
    widget.onSessionClosing?.call();
    unawaited(_eventsSubscription?.cancel() ?? Future<void>.value());
    unawaited(_session?.dispose() ?? Future<void>.value());
    _eventsSubscription = null;
    _session = null;
    super.dispose();
  }
}
