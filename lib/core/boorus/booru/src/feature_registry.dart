// Package imports:
import 'package:booru_clients/core.dart';

class BooruFeatureRegistry {
  BooruFeatureRegistry(List<BooruFeature> features)
    : _features = {for (final f in features) f.id: f};

  final Map<BooruFeatureId, BooruFeature> _features;

  T? get<T extends BooruFeature>(BooruFeatureId id) => _features[id] as T?;

  bool hasFeature(BooruFeatureId id) => _features.containsKey(id);

  Iterable<BooruFeature> get allFeatures => _features.values;

  Iterable<BooruFeatureId> get supportedFeatureIds => _features.keys;
}
