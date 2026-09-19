// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'types.dart';

final embeddedBrowserFactoryProvider = Provider<EmbeddedBrowserFactory>(
  (_) => throw UnimplementedError(
    'embeddedBrowserFactoryProvider must be overridden',
  ),
  name: 'embeddedBrowserFactoryProvider',
);
