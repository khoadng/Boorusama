import 'package:equatable/equatable.dart';

enum FeatureSortTransport {
  cookie,
  queryParameter,
}

final class FeatureSortConfig extends Equatable {
  FeatureSortConfig({
    required this.transport,
    required this.key,
    required this.defaultOrder,
    required Map<String, String> values,
  }) : values = Map.unmodifiable(values);

  final FeatureSortTransport transport;
  final String key;
  final String defaultOrder;
  final Map<String, String> values;

  FeatureSortSelection select(String? order) {
    final resolvedOrder = order ?? defaultOrder;
    final value = values[resolvedOrder];
    if (value == null) {
      throw ArgumentError.value(order, 'order', 'Unsupported sort order');
    }

    return FeatureSortSelection(
      transport: transport,
      key: key,
      value: value,
    );
  }

  @override
  List<Object?> get props => [transport, key, defaultOrder, values];
}

final class FeatureSortSelection extends Equatable {
  const FeatureSortSelection({
    required this.transport,
    required this.key,
    required this.value,
  });

  final FeatureSortTransport transport;
  final String key;
  final String value;

  @override
  List<Object?> get props => [transport, key, value];
}
