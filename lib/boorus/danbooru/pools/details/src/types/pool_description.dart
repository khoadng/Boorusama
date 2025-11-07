// Package imports:
import 'package:equatable/equatable.dart';

class PoolDescription extends Equatable {
  const PoolDescription({
    required this.description,
    required this.descriptionEndpointRefUrl,
  });
  final String description;
  final String descriptionEndpointRefUrl;

  @override
  List<Object?> get props => [
    description,
    descriptionEndpointRefUrl,
  ];
}

abstract class PoolDescriptionRepository {
  Future<String> getDescription(int poolId);
}
