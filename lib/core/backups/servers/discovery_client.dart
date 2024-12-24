// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bonsoir/bonsoir.dart';

const _defaultResolutionTimeout = Duration(seconds: 10);

class DiscoveryClient {
  DiscoveryClient({
    this.onError,
    this.onServiceFound,
    this.onServiceResolved,
    this.onServiceLost,
  });

  BonsoirDiscovery? _discovery;
  StreamSubscription? _discoverySubscription;
  final void Function(String message)? onError;
  final void Function(BonsoirService service)? onServiceFound;
  final void Function(BonsoirService service)? onServiceResolved;
  final void Function(BonsoirService service)? onServiceLost;

  bool _isDiscovering = false;
  bool get isDiscovering => _isDiscovering;

  Future<void> startDiscovery({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_isDiscovering) {
      onError?.call('Discovery already in progress');
      return;
    }

    try {
      _isDiscovering = true;
      _discovery = BonsoirDiscovery(type: '_boorusama._tcp');

      await _discovery?.ready.timeout(
        timeout,
        onTimeout: () {
          _cleanupResources();
          throw TimeoutException('Discovery initialization timed out');
        },
      );

      _discoverySubscription = _discovery?.eventStream?.listen(
        _handleDiscoveryEvent,
        onError: (e) {
          onError?.call('Discovery error: $e');
          _cleanupResources();
        },
      );

      await _discovery?.start();
    } catch (e) {
      // Catch all errors
      await _cleanupResources();
      onError?.call('Failed to start discovery: $e');
      rethrow;
    }
  }

  Future<void> _handleServiceResolution(
    BonsoirService service,
    BonsoirDiscovery discovery,
  ) async {
    try {
      await service.resolve(discovery.serviceResolver).timeout(
        _defaultResolutionTimeout,
        onTimeout: () {
          onError?.call('Service resolution timed out for ${service.name}');
          return null;
        },
      );
    } catch (e) {
      onError?.call('Service resolution failed: $e');
    }
  }

  void _handleDiscoveryEvent(BonsoirDiscoveryEvent event) {
    try {
      final service = event.service;
      final discovery = _discovery;

      if (service == null || discovery == null) {
        return;
      }

      switch (event.type) {
        case BonsoirDiscoveryEventType.discoveryServiceFound:
          onServiceFound?.call(service);
          _handleServiceResolution(service, discovery);
        case BonsoirDiscoveryEventType.discoveryServiceResolved:
          onServiceResolved?.call(service);
        case BonsoirDiscoveryEventType.discoveryServiceLost:
          onServiceLost?.call(service);
        case BonsoirDiscoveryEventType.discoveryServiceResolveFailed:
          onError?.call('Service resolve failed');
        case BonsoirDiscoveryEventType.discoveryStarted:
        case BonsoirDiscoveryEventType.discoveryStopped:
        case BonsoirDiscoveryEventType.unknown:
          break;
      }
    } catch (e) {
      onError?.call('Error handling discovery event: $e');
    }
  }

  Future<void> stopDiscovery() async {
    if (!_isDiscovering) {
      return;
    }

    try {
      await _cleanupResources();
    } catch (e) {
      onError?.call('Failed to stop discovery: $e');
      rethrow;
    }
  }

  Future<void> _cleanupResources() async {
    _isDiscovering = false;
    await _discoverySubscription?.cancel();
    _discoverySubscription = null;
    await _discovery?.stop();
    _discovery = null;
  }
}
