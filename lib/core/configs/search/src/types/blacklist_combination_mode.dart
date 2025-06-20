// Package imports:
import 'package:equatable/equatable.dart';

class BlacklistCombinationMode extends Equatable {
  const BlacklistCombinationMode({
    required this.id,
    required this.name,
    required this.description,
    this.isDefault = false,
  });

  factory BlacklistCombinationMode.fromString(String value) {
    return kBlacklistCombinationModes.firstWhere(
      (e) => e.id == value,
      orElse: () => BlacklistCombinationMode.merge,
    );
  }

  static const merge = BlacklistCombinationMode(
    id: 'merge',
    name: 'Merge',
    description: 'Merge this blacklist together with the other blacklists.',
    isDefault: true,
  );

  static const replace = BlacklistCombinationMode(
    id: 'replace',
    name: 'Replace',
    description:
        'Override global blacklist with this blacklist. Useful when you want to have a blacklist that is only used for this profile without affecting the global blacklist.',
  );

  final String id;
  final String name;
  final String description;
  final bool isDefault;

  @override
  List<Object?> get props => [name, description];
}

const kBlacklistCombinationModes = [
  BlacklistCombinationMode.merge,
  BlacklistCombinationMode.replace,
];
