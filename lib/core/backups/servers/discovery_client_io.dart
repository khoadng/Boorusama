// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bonsoir/bonsoir.dart';

// Project imports:
import '../types.dart';

const _defaultResolutionTimeout = Duration(seconds: 10);

class DiscoveryClient implements DiscoveryClientInterface {
  DiscoveryClient({
    this.onError,
    this.onServiceFound,
    this.onServiceResolved,
    this.onServiceLost,
  });

  BonsoirDiscovery? _discovery;
  StreamSubscription? _discoverySubscription;
  final void Function(String message)? onError;
  final void Function(DiscoveredService service)? onServiceFound;
  final void Function(DiscoveredService service)? onServiceResolved;
  final void Function(DiscoveredService service)? onServiceLost;

  var _isDiscovering = false;

  @override
  bool get isDiscovering => _isDiscovering;

  @override
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

      await _discovery?.initialize().timeout(
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
      await service
          .resolve(discovery.serviceResolver)
          .timeout(
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

      switch (event) {
        case BonsoirDiscoveryServiceFoundEvent():
          onServiceFound?.call(_convertService(service));
          _handleServiceResolution(service, discovery);
        case BonsoirDiscoveryServiceResolvedEvent():
          onServiceResolved?.call(_convertService(service));
        case BonsoirDiscoveryServiceLostEvent():
          onServiceLost?.call(_convertService(service));
        case BonsoirDiscoveryServiceResolveFailedEvent():
          onError?.call('Service resolve failed');
        case BonsoirDiscoveryStartedEvent():
        case BonsoirDiscoveryStoppedEvent():
        case BonsoirDiscoveryUnknownEvent():
        case BonsoirDiscoveryServiceUpdatedEvent():
          break;
      }
    } catch (e) {
      onError?.call('Error handling discovery event: $e');
    }
  }

  DiscoveredService _convertService(BonsoirService service) {
    return DiscoveredService(
      name: service.name,
      host: service.host ?? '',
      port: service.port,
      attributes: service.attributes,
    );
  }

  @override
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
