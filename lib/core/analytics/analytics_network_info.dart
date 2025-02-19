// Package imports:
import 'package:equatable/equatable.dart';

class AnalyticsNetworkInfo extends Equatable {
  const AnalyticsNetworkInfo({
    required this.types,
    required this.state,
  });

  const AnalyticsNetworkInfo.error(String message)
      : types = 'none',
        state = 'error: $message';

  const AnalyticsNetworkInfo.connected(this.types) : state = 'connected';

  const AnalyticsNetworkInfo.disconnected()
      : types = 'none',
        state = 'disconnected';

  final String types;
  final String state;

  @override
  List<Object> get props => [types, state];
}
